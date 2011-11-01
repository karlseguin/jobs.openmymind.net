require_relative File.join('..', '..', 'lib', 'settings')
require_relative File.join('..', '..', 'lib', 'store')
require 'twitter'
require 'json/ext'

Twitter.configure do |config|
  config.consumer_key = Settings.twitter['key']
  config.consumer_secret = Settings.twitter['secret']
  config.oauth_token = Settings.twitter['oauth_token']
  config.oauth_token_secret = Settings.twitter['oauth_secret']
end

module Store
  def self.get_new_jobs
    key = @@redis.lpop('jobs:new')
    key ? JSON.parse(@@redis.get(key)) : nil
  end
end
Store.setup

3.times do
  job = Store.get_new_jobs
  exit unless job
  
  location = ''
  if job['location'].is_a?(Array)
    location = job['location'].join(';')
  elsif job['location'].is_a?(String)
    location = job['location']
  end
  location = location[0..30]
  
  tweet = job['title'][0..110]
  if location.length > 0
    tweet = tweet[0..(110 - location.length)] + ' (' + location + ')'
  end
  tweet += ' ' + job['url']
  
  Twitter.update(tweet)
  sleep(1)
end