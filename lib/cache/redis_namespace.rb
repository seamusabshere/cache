require 'cache/redis'
module Cache::RedisNamespace
  def self.extended(base)
    base.extend Cache::Redis
  end
end
