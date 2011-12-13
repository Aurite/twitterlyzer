#!/usr/bin/env ruby
require 'config/environment'
@@log = Logger.new("collection.log")

task :collect_tweets do
  puts "COLLECTING TWEETS"
  @project = Project.find(ENV["project_id"].to_i)
  @project.persons.each do |person|
    Delayed::Job.enqueue(CollectAllFeedEntriesJob.new(person.id))  
  end
  Rake::Task['collect_tweets'].reenable  
end

task :collect_retweets do
  @@log.info("Started Tweet collection at #{Time.now} for project_id: #{ENV["project_id"]}")
  puts "COLLECTING RETWEETS"
  @project = Project.find(ENV["project_id"].to_i)
  continue = true
  while continue		
    found_pending_jobs = 0				
    Delayed::Job.all.each do |job|			
      if job.handler.include? "CollectAllFeedEntriesJob"
              found_pending_jobs += 1
      end
      if job.attempts >= 4
              puts "Deleting job with more than #{job.attempts} attempts."
              job.delete				
      end
    end
    if found_pending_jobs == 0
      continue = false
    end
    puts "waiting for #{found_pending_jobs} Collect Tweet Jobs to finish..."
    sleep(10)		
  end
  
  @project.persons.each do |person|
    person.feed_entries.each do |feed_entry|
      if feed_entry.retweet_count.to_i > 0
        Delayed::Job.enqueue(CollectRetweetIdsForEntryJob.new(feed_entry.id))         
      end
    end
  end
  @@log.info("Finished collection of #{@project.feed_entries(1000000).count} tweets at #{Time.now} for project_id: #{ENV["project_id"]}")
  Rake::Task['collect_retweets'].reenable  
end

task :report_success do
  puts "Waiting for SUCCESS"
  @@log.info("Started Re-Tweet collection at #{Time.now} for project_id: #{ENV["project_id"]}")
  @project = Project.find(ENV["project_id"].to_i)
  continue = true
  while continue		
    found_pending_jobs = 0				
    Delayed::Job.all.each do |job|			
      if job.handler.include? "CollectRetweetIdsForEntryJob"
              found_pending_jobs += 1
      end
      if job.attempts >= 4
              puts "Deleting job with more than #{job.attempts} attempts."
              job.delete				
      end
    end
    if found_pending_jobs == 0
      continue = false
    end
    puts "waiting for #{found_pending_jobs} Collect ReTweet Jobs to finish..."
    sleep(120)		
  end
  @@log.info("Finished collection of Re-tweets at #{Time.now} for project_id: #{ENV["project_id"]}")
end

task :collect_diffusion => [:collect_tweets, :collect_retweets, :report_success] do
    jobs = Delayed::Job.count
    puts "Finished all necessary tasks. #{jobs} remaining jobs in queue."
    Rake::Task['collect_diffusion'].reenable
end

task :collect_diffusions do
  @@communities = [17]
  @@communities.each do |community|
    ENV["project_id"] = community.to_s
    Rake::Task['collect_diffusion'].invoke
  end
end