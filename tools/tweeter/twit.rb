require_relative File.join('..', '..', 'lib', 'settings')
require_relative File.join('..', '..', 'lib', 'store')
require 'twitter'
require 'json/ext'
require 'net/http'

Twitter.configure do |config|
  config.consumer_key = Settings.twitter['key']
  config.consumer_secret = Settings.twitter['secret']
  config.oauth_token = Settings.twitter['oauth_token']
  config.oauth_token_secret = Settings.twitter['oauth_secret']
end

module Store
  def self.get_new_job_key
    key = @@redis.lpop('jobs:new')
  end
  def self.get_job(key)
    key ? JSON.parse(@@redis.get(key)) : nil
  end
end
Store.setup


job = nil
loop do
  key = Store.get_new_job_key
  job = Store.get_job(key)
  exit unless job

  break if Net::HTTP.get_response(URI.parse(job['url'])).code == '200'
  Store.client.zrem('jobs', key)
  Store.client.del(key)
end


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
tweet += ' ' + job['url'] + ' #job'

Twitter.update(tweet)