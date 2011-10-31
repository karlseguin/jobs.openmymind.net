
require 'sinatra'
require 'haml'
require './lib/store'

get '/' do
  setup_jobs
  haml :index
end

get '/rss' do
  setup_jobs
  builder :rss
end

def setup_jobs
  cache_control :public, :max_age => 360
  @jobs = Store.get_jobs
end
