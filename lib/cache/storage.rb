class Cache
  class Storage #:nodoc: all

    attr_reader :parent

    def initialize(parent)
      @parent = parent
      @pid = ::Process.pid
      @thread_object_id = ::Thread.current.object_id
    end
    
    def get(k)
      reset_if_forked_or_threaded
      if memcached?
        begin; bare_client.get(k); rescue ::Memcached::NotFound; nil; end
      elsif dalli? or memcached_rails? or mem_cache?
        bare_client.get k
      elsif redis?
        if cached_v = bare_client.get(k) and cached_v.is_a?(::String)
          ::Marshal.load cached_v
        end
      elsif active_support_store?
        bare_client.read k
      else
        raise "Don't know how to GET with #{bare_client.inspect}"
      end
    end
        
    def set(k, v, ttl)
      ttl ||= parent.config.default_ttl
      ttl = ttl.to_i
      reset_if_forked_or_threaded
      if memcached? or dalli? or memcached_rails? or mem_cache?
        bare_client.set k, v, ttl
      elsif redis?
        if ttl == 0
          bare_client.set k, ::Marshal.dump(v)
        else
          bare_client.setex k, ttl, ::Marshal.dump(v)
        end
      elsif active_support_store?
        if ttl == 0
          bare_client.write k, v # never expire
        else
          bare_client.write k, v, :expires_in => ttl
        end
      else
        raise "Don't know how to SET with #{bare_client.inspect}"
      end
    end
    
    def delete(k)
      reset_if_forked_or_threaded
      if memcached?
        begin; bare_client.delete(k); rescue ::Memcached::NotFound; nil; end
      elsif redis?
        bare_client.del k
      elsif dalli? or memcached_rails? or mem_cache? or active_support_store?
        bare_client.delete k
      else
        raise "Don't know how to DELETE with #{bare_client.inspect}"
      end
    end
    
    def flush
      reset_if_forked_or_threaded
      bare_client.send %w{ flush flushdb flush_all clear }.detect { |flush_cmd| bare_client.respond_to? flush_cmd }
    end
    
    private
    
    def bare_client
      @bare_client ||= parent.config.client
    end
    
    def reset_if_forked_or_threaded
      if fork_detected?
        $stderr.puts "fork detected" if ENV['CACHE_DEBUG'] == 'true'
        if dalli?
          parent.config.client.close
        elsif dalli_store?
          parent.config.client.reset
        elsif memcached? or memcached_rails?
          cloned_client = parent.config.client.clone
          parent.config.client = cloned_client
          @bare_client = parent.config.client
        elsif redis?
          parent.config.client.client.connect
        elsif mem_cache?
          parent.config.client.reset
        end
      elsif new_thread_detected?
        $stderr.puts "new thread detected" if ENV['CACHE_DEBUG'] == 'true'
        if memcached? or memcached_rails?
          cloned_client = parent.config.client.clone
          parent.config.client = cloned_client
          @bare_client = parent.config.client
        end
      end
    end
    
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
        
    def dalli?
      return @dalli_query[0] if @dalli_query.is_a?(::Array)
      answer = (defined?(::Dalli) and bare_client.is_a?(::Dalli::Client))
      @dalli_query = [answer]
      answer
    end
    
    def active_support_store?
      return @active_support_store_query[0] if @active_support_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache) and bare_client.is_a?(::ActiveSupport::Cache::Store))
      @active_support_store_query = [answer]
      answer
    end
    
    def dalli_store?
      return @dalli_store_query[0] if @dalli_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache::DalliStore) and bare_client.is_a?(::ActiveSupport::Cache::DalliStore))
      @dalli_store_query = [answer]
      answer
    end
    
    def memory_store?
      return @memory_store_query[0] if @memory_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache::MemoryStore) and bare_client.is_a?(::ActiveSupport::Cache::MemoryStore))
      @memory_store_query = [answer]
      answer
    end
    
    def mem_cache?
      return @mem_cache_query[0] if @mem_cache_query.is_a?(::Array)
      answer = (defined?(::MemCache) and bare_client.is_a?(::MemCache))
      @mem_cache_query = [answer]
      answer
    end

    def memcached?
      return @memcached_query[0] if @memcached_query.is_a?(::Array)
      answer = (defined?(::Memcached) and bare_client.is_a?(::Memcached))
      @memcached_query = [answer]
      answer
    end
    
    def memcached_rails?
      return @memcached_rails_query[0] if @memcached_rails_query.is_a?(::Array)
      answer = (defined?(::Memcached) and bare_client.is_a?(::Memcached::Rails))
      @memcached_rails_query = [answer]
      answer
    end
    
    def redis?
      return @redis_query[0] if @redis_query.is_a?(::Array)
      answer = (defined?(::Redis) and bare_client.is_a?(::Redis))
      @redis_query = [answer]
      answer
    end
  end
end
