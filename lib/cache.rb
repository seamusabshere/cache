require 'cache/version'
class Cache
  autoload :Config, 'cache/config'
  autoload :Storage, 'cache/storage'

  # Create a new Cache instance by wrapping a client of your choice.
  #
  # Defaults to an in-process memory store.
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
  #     cache = Cache.wrap raw_client
  def self.wrap(client = nil)
    new client
  end
  
  def initialize(client = nil) #:nodoc:
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
  def get(k, ignored_options = nil)
    storage.get k
  end
  
  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  def set(k, v, ttl = nil, ignored_options = nil)
    storage.set k, v, ttl
  end
  
  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  def delete(k, ignored_options = nil)
    storage.delete k
  end
  
  # Flush the cache.
  #
  # Example:
  #     cache.flush
  def flush
    storage.flush
  end
  
  alias :clear :flush

  # Check if something exists.
  #
  # Example:
  #     cache.exist? 'hello'
  def exist?(k, ignored_options = nil)
    storage.exist? k
  end
  
  # Increment a value.
  #
  # Example:
  #     cache.increment 'high-fives'
  def increment(k, amount = 1, ignored_options = nil)
    storage.increment k, amount
  end

  # Decrement a value.
  #
  # Example:
  #     cache.decrement 'high-fives'
  def decrement(k, amount = 1, ignored_options = nil)
    storage.decrement k, amount
  end
  
  # Reset the cache connection. You shouldn't really use this, because it happens automatically on forking/threading.
  def reset
    storage.reset
  end

  # Try to get a value and if it doesn't exist, set it to the result of the block.
  #
  # Example:
  #     cache.fetch 'hello' { 'world' }
  def fetch(k, options_ignored_except_expires_in = {}, &blk)
    storage.fetch k, options_ignored_except_expires_in[:expires_in], &blk
  end
  
  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  def cas(k, ttl = nil, &blk)
    storage.cas k, ttl, &blk
  end
  
  alias :compare_and_swap :cas
  
  # Get stats.
  #
  # Example:
  #     cache.stats
  def stats
    storage.stats
  end
  
  def write(k, v, options_ignored_except_expires_in = {}) #:nodoc:
    storage.set k, v, options_ignored_except_expires_in[:expires_in]
  end
  
  def read(k, ignored_options = nil) #:nodoc:
    storage.get k
  end
  
  def read_multi(*ks) #:nodoc:
    ks.map { |k| storage.get k }
  end
end
