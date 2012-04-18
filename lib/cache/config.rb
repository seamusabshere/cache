class Cache
  # Here's where config options are kept.
  #
  # Example:
  #     cache.config.default_ttl = 120 # seconds
  class Config
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
  end
end
