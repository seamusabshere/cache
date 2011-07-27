class Cache
  # Here's where config options are kept.
  #
  # Example:
  #     cache.config.default_ttl = 120 # seconds
  class Config
    
    attr_reader :parent
    
    def initialize(parent) #:nodoc:
      @parent = parent
    end
    
    # The cache client to use.
    #
    # Note that you normally just set this when you initialize a Cache object.
    #
    # Example:
    #     cache.config.client = Memcached.new '127.0.0.1:11211'
    def client=(client) #:nodoc:
      @client = client.is_a?(::Cache) ? client.config.client : client
    end

    def client #:nodoc:
      if @client.nil?
        self.client = if defined?(::Rails) and ::Rails.respond_to?(:cache) and rails_cache = ::Rails.cache and not rails_cache.is_a?(::Cache)
          rails_cache
        else
          require 'active_support/cache'
          require 'active_support/cache/memory_store'
          ::ActiveSupport::Cache::MemoryStore.new
        end
      else
        @client
      end
    end
    
    # TTL for method caches. Defaults to 60 seconds.
    #
    # Example:
    #     cache.config.default_ttl = 120 # seconds
    def default_ttl=(seconds)
      @default_ttl = seconds
    end
    
    def default_ttl #:nodoc:
      @default_ttl || 60
    end
    
    def logger #:nodoc:
      @logger
    end
    
    def logger=(logger) #:nodoc:
      @logger = logger
    end
  end
end
