require 'redis'
require 'json/ext'
#require 'rubberband'
#require 'sanitize'


$redis = Redis.new
$redis.select(5)

#$es = ElasticSearch.new('127.0.0.1:9200', :index => "jobs", :type => "job")

module Store
  def self.insert(job)
    key = "#{job[:source]}:#{job[:source_id]}"
    full_key = "job:#{key}"
    serialized_job = job.to_json
    if $redis.exists(full_key)
      $redis.set(full_key, serialized_job)
    else
      $redis.multi do
        $redis.set(full_key, serialized_job)
        $redis.zadd('jobs', job[:created_at].to_i, full_key)
      end
    end
    #$es.index({:description => Sanitize.clean(job[:description]), :location => job[:location]}, :id => key)
  end
end
