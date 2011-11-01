require_relative File.join('..', '..', 'lib', 'store')

module Store
  def self.clean
    keys = @@redis.zrange('jobs', 0, -500)
    return unless keys.length > 0
    
    @@redis.del(*keys)
    keys.each {|key| @@redis.zrem('jobs', key)}
  end
end
Store.setup
Store.clean