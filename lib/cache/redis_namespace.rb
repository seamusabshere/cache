require 'cache/redis_namespace'
module Cache::RedisNamespace
  def self.extended(base)
    base.extend Cache::Redis
  end
end
