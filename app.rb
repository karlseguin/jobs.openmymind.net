require 'sinatra'
require 'haml'
require './lib/store'

get '/' do
  setup_jobs
  haml :index
end

get '/rss' do
  setup_jobs
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title "coder jobs"
        xml.description "Aggregating jobs from github, stackoverflow, 37 signals, node.js and hasgeek since 2011"
        xml.link "http://jobs.openmymind.net/"  
        @jobs.each do |job|
          xml.item do
            xml.title job['title']
            xml.link job['url']
            xml.description job['description']
            xml.pubDate job['created_at'].rfc822()
            xml.guid job['url']
          end
        end
      end
    end
  end
end

def setup_jobs
  cache_control :public, :max_age => 60
  @jobs = Store.get_jobs
end
