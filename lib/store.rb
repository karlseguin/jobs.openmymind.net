require 'redis'
require 'json/ext'
require File.dirname(__FILE__) + '/settings'

module Store  
  def self.setup
    @@redis = Redis.new(:host => Settings.redis['host'], :port => Settings.redis['port'])
    @@redis.select(Settings.redis['database'])
    handle_passenger_forking
  end
  
  def self.client
    @@redis
  end
  
  def self.get_jobs
    (@@redis.mget(*@@redis.zrevrange('jobs', 0, 250)).map do |j|
      next unless j
      job = JSON.parse(j)
      job['created_at'] = Time.at(job['created_at'])
      job
    end).compact
  end
  
  def self.handle_passenger_forking
    if defined?(PhusionPassenger)
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        if forked
          @@redis.client.reconnect
          @@redis.select(Settings.redis['database'])
        end
      end
    end
  end
end