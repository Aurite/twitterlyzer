# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION
require 'csv'
require 'rubygems'
require 'grackle'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

#Constants
STOP_WORDS = File.new(RAILS_ROOT + "/public/stopwords.txt").readlines.map {|line| line.chomp}
TWITTER_USERNAME = "plotti"
TWITTER_PASSWORD = "wrzesz"
FRIENDS_IDS_PATH = RAILS_ROOT + "/friends_ids_data/"
FOLLOWER_IDS_PATH = RAILS_ROOT  + "/follower_ids_data/"

#Twitter Client
CONSUMER_KEY = "lPeEtUCou8uFFOBt94h3Q"
CONSUMER_SECRET = "iBFQqoV9a5qKCiAfitEXFzvkD7jcpSFupG8FBGWE"
ACCESS_TOKEN = "15533871-abkroGVmE7m1oJGzZ38L29c7o7vDyGGSevx6X25kA"
ACCESS_TOKEN_SECRET = "pAoyFeGQlHr53BiRSxpTUpVtQW0B0zMRKBHC3hm3s"
@@client = Grackle::Client.new(:auth=>{
  :type=>:oauth,
  :consumer_key=>CONSUMER_KEY, :consumer_secret=>CONSUMER_SECRET,
  :token=>ACCESS_TOKEN, :token_secret=>ACCESS_TOKEN_SECRET
})

#read in cities hash
temp = Hash.new
CSV.read(RAILS_ROOT + '/public/cities_map.csv').each{|row| temp[row[0]] = row[1]}
CITIES_MAP = temp

#Uniq function
class Array
  def uniq_by
    seen = Set.new
    select{ |x| seen.add?(yield(x))}
  end
end

#Create dirs
FileUtils.mkdir_p FRIENDS_IDS_PATH
FileUtils.mkdir_p FOLLOWER_IDS_PATH
  
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  #config.gem "pauldix-feedzirra", :lib => "feedzirra", :source => "http://gems.github.com"
  config.gem 'javan-whenever', :lib => false, :source => 'http://gems.github.com'
  config.gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
  #config.gem 'rsruby'
  
end
