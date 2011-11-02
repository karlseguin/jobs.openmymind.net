require 'json/ext'
require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'store')
#require 'rubberband'
#require 'sanitize'

#$es = ElasticSearch.new('127.0.0.1:9200', :index => "jobs", :type => "job")

module Store
  def self.insert(job)
    return if Time.now.to_i - job[:created_at] > 86400
    
    key = "job:#{job[:source]}:#{job[:source_id]}"
    serialized_job = job.to_json
    if @@redis.exists(key)
      @@redis.set(key, serialized_job)
    else
      @@redis.multi do
        @@redis.set(key, serialized_job)
        @@redis.zadd('jobs', job[:created_at], key)
        @@redis.rpush('jobs:new', key)
      end
    end
    #$es.index({:description => Sanitize.clean(job[:description]), :location => job[:location]}, :id => key)
  end
end


Store.setup