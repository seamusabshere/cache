class Cache
  class Storage #:nodoc: all

    attr_reader :parent

    def initialize(parent)
      @parent = parent
      @pid = ::Process.pid
      @thread_object_id = ::Thread.current.object_id
    end
    
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
      ttl ||= parent.config.default_ttl
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
    
    private
    
    def fork_detected?
      if @pid != ::Process.pid
        @pid = ::Process.pid
      end
    end
    
    def new_thread_detected?
      if @thread_object_id != ::Thread.current.object_id
        @thread_object_id = ::Thread.current.object_id
      end
    end
    
    def bare_client
      fork_detected = fork_detected?
      new_thread_detected = new_thread_detected?
      if defined?(::Dalli) and parent.config.client.is_a?(::Dalli::Client)
        parent.config.client.close if fork_detected
      elsif defined?(::ActiveSupport::Cache::DalliStore) and parent.config.client.is_a?(::ActiveSupport::Cache::DalliStore)
        parent.config.client.reset if fork_detected
      elsif defined?(::Memcached) and (parent.config.client.is_a?(::Memcached) or parent.config.client.is_a?(::Memcached::Rails))
        parent.config.client = parent.config.client.clone if fork_detected or new_thread_detected
      elsif defined?(::Redis) and parent.config.client.is_a?(::Redis)
        parent.config.client.client.connect if fork_detected
      elsif defined?(::MemCache) and parent.config.client.is_a?(::MemCache)
        parent.config.client.reset if fork_detected
      else
        raise "Don't know how to thread/fork #{parent.config.client.inspect}"
      end
      parent.config.client
    end
  end
end
