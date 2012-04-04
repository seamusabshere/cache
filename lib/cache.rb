require 'active_support/core_ext'
require 'cache/config'
require 'cache/wrapper'

class Cache
  # Create a new Cache instance by wrapping a client of your choice.
  #
  # Defaults to an in-process memory store.
  #
  # Supported memcached clients:
  # * memcached[https://github.com/evan/memcached] (either a Memcached or a Memcached::Rails)
  # * dalli[https://github.com/mperham/dalli] (either a Dalli::Client or an ActiveSupport::Cache::DalliStore)
  # * memcache-client[https://github.com/mperham/memcache-client] (MemCache, the one commonly used by Rails)
  #
  # Supported Redis clients:
  # * redis[https://github.com/ezmobius/redis-rb]
  #
  # Example:
  #     raw_client = Memcached.new('127.0.0.1:11211')
  #     cache = Cache.wrap raw_client
  def self.wrap(metal = nil)
    new metal
  end
  
  attr_reader :config

  def initialize(metal = nil) #:nodoc:
    @config = Config.new self
    @wrapper = if metal.is_a?(Cache)
      metal.instance_variable_get(:@wrapper)
    elsif metal
      Wrapper.wrap metal
    elsif defined?(::Rails) and ::Rails.respond_to?(:cache) and rails_cache = ::Rails.cache
      Wrapper.wrap rails_cache
    else
      require 'active_support/cache'
      require 'active_support/cache/memory_store'
      Wrapper.wrap ::ActiveSupport::Cache::MemoryStore.new
    end
  end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  def get(k, ignored_options = nil)
    @wrapper.get k
  end
  
  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  def set(k, v, ttl = nil, ignored_options = nil)
    @wrapper.set k, v, extract_ttl(ttl)
  end
  
  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  def delete(k, ignored_options = nil)
    @wrapper.delete k
  end
  
  # Flush the cache.
  #
  # Example:
  #     cache.flush
  def flush
    @wrapper.flush
  end
  
  alias :clear :flush

  # Check if something exists.
  #
  # Example:
  #     cache.exist? 'hello'
  def exist?(k, ignored_options = nil)
    @wrapper.exist? k
  end
  
  # Increment a value.
  #
  # Example:
  #     cache.increment 'high-fives'
  def increment(k, amount = 1, ignored_options = nil)
    @wrapper.increment k, amount
  end

  # Decrement a value.
  #
  # Example:
  #     cache.decrement 'high-fives'
  def decrement(k, amount = 1, ignored_options = nil)
    @wrapper.decrement k, amount
  end
  
  # Reset the cache connection. You shouldn't really use this, because it happens automatically on forking/threading.
  def reset
    @wrapper.reset
  end

  # Try to get a value and if it doesn't exist, set it to the result of the block.
  #
  # Accepts :expires_in for compatibility with Rails.
  #
  # Example:
  #     cache.fetch 'hello' { 'world' }
  def fetch(k, ttl = nil, &blk)
    @wrapper.fetch k, extract_ttl(ttl), &blk
  end
  
  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  def cas(k, ttl = nil, &blk)
    @wrapper.cas k, extract_ttl(ttl), &blk
  end
  
  alias :compare_and_swap :cas
  
  # Get stats.
  #
  # Example:
  #     cache.stats
  def stats
    @wrapper.stats
  end

  # Get multiple cache entries.
  #
  # Example:
  #     cache.get_multi 'hello', 'privyet'
  def get_multi(*ks)
    @wrapper.get_multi ks
  end
  
  # Like get, but accepts :expires_in for compatibility with Rails.
  #
  # In general, you should use get instead.
  #
  # Example:
  #     cache.write 'hello', 'world', :expires_in => 5.minutes
  def write(k, v, ttl = nil)
    @wrapper.set k, v, extract_ttl(ttl)
  end
  
  def read(k, ignored_options = nil) #:nodoc:
    @wrapper.get k
  end
    
  private
  
  def extract_ttl(ttl)
    case ttl
    when ::Hash
      ttl[:expires_in] || ttl['expires_in'] || ttl[:ttl] || ttl['ttl'] || config.default_ttl
    when ::NilClass
      config.default_ttl
    else
      ttl
    end.to_i
  end
end
