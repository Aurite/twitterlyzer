class Project < ActiveRecord::Base
  require "graphviz"
  require "csv"
  require 'scrapi'
  #require 'igraph'

  #associations
  has_and_belongs_to_many :persons
  has_many :searches
  has_many :lists
  has_many :system_messages, :as => :messageable

  WEFOLLOW_BASE_URL = "http://wefollow.com/twitter/"
  
  @@wefollow_scraper = Scraper.define do
    array :items
    #div+div>div.person-box
    process "#results>div", :items => Scraper.define {
      #process "div", :name => :text
      process "div.result_row>div.result_details>p>strong>a", :name => :text     
    }    
    result :items
  end
    
  def self.graph_net(project_id)  
    project = Project.find(project_id)
    persons = project.persons       
    g = GraphViz::new( "G" )    
    project_net = project.find_all_connections(friend = true, follower = false)
    
    #add nodes and edges
    project_net.each do |entry|
      g.add_node(entry[0])
      g.add_edge(entry[0],entry[1])
      g.output( :output => "png", :use=> "fdp", :file => "#{project.name.gsub!(" ","_")}.png" )
    end
  end
  
  
  def self.find_k_cores(project_id, core)
    project = Project.find(project_id)
    persons = project.persons    
    followers = project.followers
    
    g = IGraph.new([],true)
    
    followers.each do |follower|
      follower_id = Person.find_by_username(follower.person).id
      followed_by_id = Person.find_by_username(follower.followed_by_person).id
      edges << follower_id
      edges << followed_by_id
      #g.add_vertex(follower_id)
      #g.add_vertex(followed_by_id)
      #g.add_edge(follower_id, followed_by_id)
    end
    
    return g
  end
  
  #Write project people net to disk
  def self.write_net_to_disk
    content_type = ' text/csv '    
    Project.all.each do |project|      
      if project.monitor_feeds == true
        project_net = project.find_all_connections(friend = true, follower = false)                
        outfile = File.open(RAILS_ROOT + "/log/" + project.name + "_SNA_" + Time.now.strftime("%d_%m_%Y %I:%M").to_s + ".csv", 'w')      
        CSV::Writer.generate(outfile) do |csv|
          csv << ["DL n=" + project.persons.count.to_s ]
          csv << ["format = edgelist1"]
          csv << ["labels embedded:"]
          csv << ["data:"]
          project_net.each do |entry|
            csv << [entry[0], entry[1], "1"]
          end
        end
        outfile.close
        SystemMessage.add_message("info", "Write net to disk", project.name + " net was written to disk.")          
      end
    end
  end
  
  #Write project stats to disk 
  def self.write_stats_to_disk
    content_type = ' text/csv '
    Project.all.each do |project|      
      if project.monitor_feeds == true
        outfile = File.open(RAILS_ROOT + "/log/" + project.name + "_STATS_" + Time.now.strftime("%d_%m_%Y %I:%M").to_s + ".csv", 'w')      
        CSV::Writer.generate(outfile) do |csv|
          csv << ["Person", "Twitter_Username", "Friends", "Followers", "Messages"]
          project.persons.each do |person|
            csv << [person.name, person.username, person.friends_count, person.followers_count, person.statuses_count]
          end
        end
        outfile.close
        SystemMessage.add_message("info", "Write stats to disk", project.name + " stats were written to disk.")          
      end
    end
  end
  
  #def add_members_to_my_list(listname)
  #  l = @@twitter.lists :name => listname
  #  twitter_ids = project.persons.collect{|p| p.twitter_id}
    #twitter_ids.each do |id|
    # @@twitter.list_add_members(TWITTER_USERNAME, l.lists.first.id, id )    
    #end
    #
  #end
  
  def generate_new_project_from_most_listed_members
      @tmp_persons = []
      self.persons.each do |person|
        @tmp_persons << {:username => person.username, :list_count => 1,
          :uri => "http://www.twitter.com/#{person.username}", :followers => person.followers_count,
          :friends => person.friends_count}
      end
      self.lists.each do |list|
        if list.name.include? self.keyword        
          puts "#{@tmp_persons.count} Analyzing list #{list.name}"
          if list.members
            list.members.each do |member|
              tmp_user = @tmp_persons.find{|i| i[:username] == member[:username]}
              if tmp_user != nil
                tmp_user[:list_count] += 1
              else
                @tmp_persons << {:username => member[:username], :list_count => 1,
                  :uri => "http://www.twitter.com/#{member[:username]}", :followers => member[:followers_count],
                  :friends => member[:friends_count]}
              end
            end
          end
        end
      end      
      sorted = @tmp_persons.sort{|a,b| a[:list_count] <=> b[:list_count]}.reverse
      outfile = File.open(self.keyword + "_sorted_members.csv",'w')
      CSV::Writer.generate(outfile) do |csv|
        csv << ["Username", "Followers", "List Count", "URI"]
        sorted.each do |member|
          csv << [member[:username], member[:followers], member[:list_count], member[:uri]]
        end
      end
      outfile.close
      return sorted
  end
  
  def add_people_from_wefollow(pages)
    for page in 1..pages
        if page == 1
          uri = URI.parse(WEFOLLOW_BASE_URL + self.keyword + "/followers") 
        else
          uri = URI.parse(WEFOLLOW_BASE_URL + self.keyword + "/page#{page}" + "/followers")   
        end        
        puts uri
        begin
          @@wefollow_scraper.scrape(uri).each do |person|
            result_string = "http://twitter.com/" + person.name
            puts result_string
            username = URI.parse(result_string).path.reverse.chop.reverse
            maxfriends = 10000
            category = ""
            Delayed::Job.enqueue(CollectPersonJob.new(username,self.id,maxfriends,category))  
          end
        rescue
          puts "Couldnt find any page for #{uri}"
        end
    end

  end
  
  #Tries to find all connections for a given project
  def find_all_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_ids = []
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_ids << person.twitter_id
    end    
    persons.each do |person|      
      i = i+1
      if friend
        logger.info("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        persons_ids.each do |person_id|
          if friends_ids_hash.include?(person_id)
            values << [Person.find_by_twitter_id(person_id).username, person.username.to_s]
          end
        end        
      end
      if follower
        logger.info("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for follower connections.")          
        follower_ids_hash = person.follower_ids_hash
        persons_ids.each do |person_id|
          if follower_ids_hash.include?(person_id)
            values << [Person.find_by_twitter_id(person_id).username, person.username.to_s]
          end
        end  
      end
    end
    return values 
  end
  
  def self.find_all_persons_connections(persons)
    i= 0
    values = []
    persons_ids = []
    persons.each do |person|
      persons_ids << person.twitter_id
    end
    persons.each do |person|      
      i = i+1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
      friends_ids_hash = person.friends_ids_hash
      persons_ids.each do |person_id|
        if friends_ids_hash.include?(person_id)
          values << [person_id, person.twitter_id]
        end
      end       
    end
    return values
  end
  
  #For  a given project
  #For all persons tweets in the project check if they have been retweeted by other members in the community
  def find_all_retweet_connections(friend = true,follower = false,category = false)
    values = []
    i = 0    
    persons.each do |person|
    i += 1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for retweet connections.")
      values += find_retweet_connections_for_person(person,false,category)
    end
    #Merge counted pairs
    hash = values.group_by { |first, second, third| [first,second] }
    return hash.map{|k,v| [k,v.count].flatten}    
  end
  
  def find_retweet_connections_for_person(person,following = false,category = false)
    puts "Finding retweet connections with following:#{following} category:#{category}"
    values = []
    usernames = persons.collect{|p| p.username}        
    person.feed_entries.each do |tweet|
      tweet.retweet_ids.each do |retweet|          
        if usernames.include? retweet[:person]
          #the person that retweets a user must follow that person to be valid
          if following
            if Person.find_by_username(retweet[:person]).friends_ids.include? person.twitter_id
              values << [person.username, retweet[:person],1]
            end
          else
            #Only count retweets that are between different categories
            if category
              if Person.find_by_username(retweet[:person]).category != person.category
                values << [person.username, retweet[:person],1]
              end
            else
              values << [person.username, retweet[:person],1]
            end
          end
        end
      end
    end
    return values
  end
  
  # For a given project it:
  # Looks through the people contained in a project
  # and for each person it goes through its tweets and looks if that person
  # is mentioning a person in the project. If it finds a mention of the other person
  # it also checks if that is maybe a retweet of that person
  # This makes sure that we only get the @ communication without the RT.
  # Everytime we find somebody we set the value up.
  def find_all_valued_connections(friend = true, follower = false, category = false)
    if category
      puts "COMPUTING CATEGORY only @ Interactions"
    end
    values = []
    usernames = persons.collect{|p| p.username}
    i = 0
    persons.each do |person|
      i += 1
      puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for talk connections.")          
      person.feed_entries.each do |tweet|
        usernames.each do |tmp_user|
          if tweet.text.include?("@" + tmp_user + " ")            
            if category 
              if person.category != Person.find_by_username(tmp_user).category
                if tweet.retweet_ids == []
                  values << [tmp_user,person.username,1]  
                end                             
              end
            else
              #if the tweet has not been retweeted hence is not a retweet
              if tweet.retweet_ids == []
                values << [tmp_user,person.username,1]  
              end             
            end
          end                  
        end
      end      
    end
    #Merge counted pairs
    hash = values.group_by { |first, second, third| [first,second] }
    return hash.map{|k,v| [k,v.count].flatten}  
  end

  
  #Analytic function that returns the amount of collected tweets vs. the
  # amount of tweets that should have had been collected according to the statuses_count
  def get_tweet_delta
    puts "The delta are due to the 'include rts' function that filters out tweets not originating from that person"
    r = {}
    r[:count] = 0
    r[:message] = []
    r[:persons] = []
     self.persons.each do |person|
       if person.statuses_count != person.feed_entries.count
         person.statuses_count < 3200 ? max = person.statuses_count : max = 3200  
         r[:message] << "Person Username: #{person.username} max: #{max} delta: #{max - person.feed_entries.count}"
         r[:count] += max - person.feed_entries.count
         r[:persons] << person
       end
     end     
     return r
  end
  
  #Analytic function that returns the delta between the collected retweets and
  #and how many should HAVE HAD been collected according to the retweet-count.
  def get_retweet_delta
    r = {}
    r[:count] = 0
    r[:message] = []
    r[:feeds] = []
    self.persons.each do |person|
      person.feed_entries.each do |f|
       if f.retweet_count.to_i != f.retweet_ids.count          
          delta = f.retweet_count.to_i - f.retweet_ids.count
          if delta > 1
            r[:message] << "Person Username: #{person.username} tweet: #{f.guid} delta: #{delta}"
            r[:feeds] << f
          end
          r[:count] += delta
       end         
      end
    end     
    return r
  end
  
  def find_all_id_connections(friend = true, follower = false)
    i= 0
    values = []
    persons_ids = []
    persons = Project.find(self.id).persons    
    persons.each do |person|
      persons_ids << person.twitter_id
    end    
    persons.each do |person|      
      i = i+1
      if friend
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for friend connections.")          
        friends_ids_hash = person.friends_ids_hash
        persons_ids.each do |person_id|
          if friends_ids_hash.include?(person_id)
            values << [person.twitter_id,person_id]
          end
        end        
      end
      if follower
        puts("Analyzing ( " + i.to_s + "/" + persons.count.to_s + ") " + person.username + " for follower connections.")          
        follower_ids_hash = person.follower_ids_hash
        persons_ids.each do |person_id|
          if follower_ids_hash.include?(person_id)
            values << [person_id, person.twitter_id]
          end
        end  
      end
    end
    return values 
  end
  
  def feed_entries(limit)
    FeedEntry.find(:all, :conditions => [ "person_id IN (?)", self.persons], :limit => limit)    
  end
  

  def feed_entries_count
    r  = 0 
    self.persons.each do |p|
      r += p.feed_entries.count 
    end
    return r
  end
  
end
