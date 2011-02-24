require 'cache/version'
class Cache
  autoload :Config, 'cache/config'
  autoload :Storage, 'cache/storage'

  # Create a new Cache object by passing it a client of your choice.
  #
  # Defaults to an in-process memory store, but you probably don't want that.
  #
  # Supported memcached clients:
  # * memcached[https://github.com/fauna/memcached] (either a Memcached or a Memcached::Rails)
  # * dalli[https://github.com/mperham/dalli] (either a Dalli::Client or an ActiveSupport::Cache::DalliStore)
  # * memcache-client[https://github.com/mperham/memcache-client] (MemCache, the one commonly used by Rails)
  #
  # Supported Redis clients:
  # * redis[https://github.com/ezmobius/redis-rb]
  #
  # Example:
  #     raw_client = Memcached.new('127.0.0.1:11211')
  #     cache = Cache.new raw_client
  def initialize(client = nil)
    config.client = client
  end

  def config #:nodoc:
    @config ||= Config.new self
  end

  def storage #:nodoc:
    @storage ||= Storage.new self
  end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  def get(k)
    storage.get k
  end
  
  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  def set(k, v, ttl = nil)
    storage.set k, v, ttl
  end
  
  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  def delete(k)
    storage.delete k
  end
  
  # Flush the cache.
  #
  # Example:
  #     cache.flush
  def flush
    storage.flush
  end
end
