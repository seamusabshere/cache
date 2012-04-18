require 'active_support/core_ext'
require 'cache/config'

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
  attr_reader :metal

  # For compatibility with Rails 2.x
  attr_accessor :logger

  def initialize(metal = nil) #:nodoc:
    @pid = ::Process.pid
    @config = Config.new
    @metal = if metal.is_a?(Cache)
      metal.metal
    elsif metal
      metal
    elsif defined?(::Rails) and ::Rails.respond_to?(:cache) and rails_cache = ::Rails.cache
      rails_cache
    else
      require 'active_support/cache'
      require 'active_support/cache/memory_store'
      ::ActiveSupport::Cache::MemoryStore.new
    end
    metal_class = @metal.class.name.delete('::') # Memcached::Rails -> 'MemcachedRails'
    require "cache/#{metal_class.underscore}"
    extend Cache.const_get(metal_class)
  end

  # Get a value.
  #
  # Example:
  #     cache.get 'hello'
  def get(k, ignored_options = nil)
    handle_fork
    _get k
  end

  alias :read :get

  # Get multiple cache entries.
  #
  # Example:
  #     cache.get_multi 'hello', 'privyet'
  def get_multi(*ks)
    handle_fork
    _get_multi ks
  end

  # Store a value. Note that this will Marshal it.
  #
  # Example:
  #     cache.set 'hello', 'world'
  #     cache.set 'hello', 'world', 80 # seconds til it expires
  def set(k, v, ttl = nil, ignored_options = nil)
    handle_fork
    _set k, v, extract_ttl(ttl)
  end

  alias :write :set

  # Delete a value.
  #
  # Example:
  #     cache.delete 'hello'
  def delete(k, ignored_options = nil)
    handle_fork
    _delete k
  end

  # Flush the cache.
  #
  # Example:
  #     cache.flush
  def flush
    handle_fork
    _flush
  end

  alias :clear :flush

  # Check if something exists.
  #
  # Example:
  #     cache.exist? 'hello'
  def exist?(k, ignored_options = nil)
    handle_fork
    _exist? k
  end

  # Increment a value.
  #
  # Example:
  #     cache.increment 'high-fives'
  def increment(k, amount = 1, ignored_options = nil)
    handle_fork
    new_v = _get(k).to_i + amount
    _set k, new_v, 0
    new_v
  end

  # Decrement a value.
  #
  # Example:
  #     cache.decrement 'high-fives'
  def decrement(k, amount = 1, ignored_options = nil)
    increment k, -amount
  end

  # Try to get a value and if it doesn't exist, set it to the result of the block.
  #
  # Accepts :expires_in for compatibility with Rails.
  #
  # Example:
  #     cache.fetch 'hello' { 'world' }
  def fetch(k, ttl = nil, &blk)
    handle_fork
    if _exist? k
      _get k
    elsif blk
      v = blk.call
      _set k, v, extract_ttl(ttl)
      v
    end
  end

  # Get the current value (if any), pass it into a block, and set the result.
  #
  # Example:
  #     cache.cas 'hello' { |current| 'world' }
  def cas(k, ttl = nil, &blk)
    handle_fork
    if blk and _exist?(k)
      old_v = _get k
      new_v = blk.call old_v
      _set k, new_v, extract_ttl(ttl)
      new_v
    end
  end

  alias :compare_and_swap :cas

  # Get stats.
  #
  # Example:
  #     cache.stats
  def stats
    handle_fork
    _stats
  end

  private
  
  def handle_fork
    if ::Process.pid != @pid
      @pid = ::Process.pid
      after_fork
    end
  end

  def after_fork
    # nothing
  end

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
