#This file outputs overviews on the person level

require '../config/environment'

outfile = CSV.open("#{RAILS_ROOT}/analysis/results/stats/person_stats.csv", "wb")
outfile << ["Community", "Person ID", "Person Name", "Private?", "Deleted?", "Friends Count", "Friends_IDS", "Delta Friends", "Followers Count",
            "Statuses Count", "# Tweets", "Delta Tweets", "# Retweets stored in DB", "# Retweets reported by Twitter", "Delta Retweets"]

#Decide on a final partition
members = FasterCSV.read("#{RAILS_ROOT}/analysis/data/partitions/final_partitions_p100_200_0.2.csv")
i = 0

members.each do |member|
  i += 1
    
  person = "NaN"
  private = "NaN"
  person_id = "NaN"
  person_username = member[0]
  feed_entries_count,followers_count, statuses_count, friends_count,friends_ids_count,retweets_in_db,retweets_by_twitter = 0,0,0,0,0,0,0
  deleted = false
  delta_friends, delta_statuses, delta_retweets = 0,0,0
  
  puts "Working on member #{i}: #{member[0]}"  
  person = Person.find_by_username(member[0])  
  community = member[1]
  
  if person != nil
    
    #Get basic details
    person_id = person.id
    private = person.private
    friends_count = person.friends_count
    followers_count = person.followers_count
    statuses_count = person.statuses_count
    feed_entries_count =person.feed_entries.count
    friends_ids_count = person.friends_ids.count
    
    #Check Feed Entries
    if person.feed_entries.count == 0      
      # For persons without tweets check if they have been deleted by Twitter
      begin
        if Project.get_remaining_hits != "timeout"
          puts "Checking person #{person.username}"
          status = @@twitter.user(person.username)          
        end          
      rescue
        status = ""
      end          
      if status == ""
        person.d2 = "deleted"
        person.save!
        deleted = true
      end  
    end
    
    #Check Retweets          
    if person.d1 == nil      
      # Count how many actual retweet traces we have stored in the db
      retweets_in_db = person.feed_entries.inject(0){|r,f| r+=f.retweet_ids.count}            
      # Count how many retweets Twitter reports (This is not accurate Twitter says)
      retweets_by_twitter = person.feed_entries.inject(0){|r,f| r+=f.retweet_count.to_i}        
      person.d1 = retweets_in_db
      person.save!        
    else      
      retweets_in_db = person.d1
      retweets_by_twitter = person.feed_entries.inject(0){|r,f| r+=f.retweet_count.to_i}      
    end
    
  end
  
  # Calculate the difference between what we have and what we are supposed to have
  delta_friends = friends_count - friends_ids_count
  if statuses_count < 3200
    delta_statuses = statuses_count - feed_entries_count
  else
    delta_statuses = 3200 -feed_entries_count
  end
  delta_retweets = retweets_by_twitter - retweets_in_db
  
  outfile << [community, person_id, person_username, private, deleted, friends_count, friends_ids_count, delta_friends, followers_count, statuses_count,
              feed_entries_count, delta_statuses, retweets_by_twitter, retweets_in_db, delta_retweets]
end

outfile.close