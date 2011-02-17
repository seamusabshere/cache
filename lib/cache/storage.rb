require 'singleton'
module Cache
  class Storage #:nodoc: all
    include ::Singleton
        
    def get(k)
      if defined?(::Memcached) and bare_client.is_a?(::Memcached)
        begin; bare_client.get(k); rescue ::Memcached::NotFound; nil; end
      elsif defined?(::Redis) and bare_client.is_a?(::Redis)
        if cached_v = bare_client.get(k) and cached_v.is_a?(::String)
          ::Marshal.load cached_v
        end
      elsif bare_client.respond_to?(:get)
        bare_client.get k
      elsif bare_client.respond_to?(:read)
        bare_client.read k
      else
        raise "Don't know how to work with #{bare_client.inspect} because it doesn't define get"
      end
    end
        
    def set(k, v, ttl)
      ttl ||= Config.instance.default_ttl
      if defined?(::Redis) and bare_client.is_a?(::Redis)
        if ttl == 0
          bare_client.set k, ::Marshal.dump(v)
        else
          bare_client.setex k, ttl, ::Marshal.dump(v)
        end
      elsif bare_client.respond_to?(:set)
        bare_client.set k, v, ttl
      elsif bare_client.respond_to?(:write)
        if ttl == 0
          bare_client.write k, v # never expire
        else
          bare_client.write k, v, :expires_in => ttl
        end
      else
        raise "Don't know how to work with #{bare_client.inspect} because it doesn't define set"
      end
    end
    
    def delete(k)
      if defined?(::Memcached) and bare_client.is_a?(::Memcached)
        begin; bare_client.delete(k); rescue ::Memcached::NotFound; nil; end
      elsif defined?(::Redis) and bare_client.is_a?(::Redis)
        bare_client.del k
      elsif bare_client.respond_to?(:delete)
        bare_client.delete k
      else
        raise "Don't know how to work with #{bare_client.inspect} because it doesn't define delete"
      end
    end
    
    def flush
      bare_client.send %w{ flush flushdb flush_all clear }.detect { |flush_cmd| bare_client.respond_to? flush_cmd }
    end
    
    def bare_client
      Config.instance.client
    end
  end
end
