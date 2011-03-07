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
        begin; bare.get(k); rescue ::Memcached::NotFound; nil; end
      elsif dalli? or memcached_rails? or mem_cache?
        bare.get k
      elsif redis?
        if cached_v = bare.get(k) and cached_v.is_a?(::String)
          ::Marshal.load cached_v
        end
      elsif active_support_store?
        bare.read k
      else
        raise "Don't know how to GET with #{bare.inspect}"
      end
    end
    
    def get_multi(ks)
      reset_if_forked_or_threaded
      if memcached?
        bare.get ks
      elsif memcached_rails? or dalli? or mem_cache?
        bare.get_multi ks
      elsif active_support_store?
        bare.read_multi *ks
      else
        ks.inject({}) do |memo, k|
          memo[k] = get k if exist? k
          memo
        end
      end
    end
        
    def set(k, v, ttl)
      reset_if_forked_or_threaded
      if memcached? or dalli? or memcached_rails? or mem_cache?
        bare.set k, v, ttl
      elsif redis?
        if ttl == 0
          bare.set k, ::Marshal.dump(v)
        else
          bare.setex k, ttl, ::Marshal.dump(v)
        end
      elsif active_support_store?
        if ttl == 0
          bare.write k, v # never expire
        else
          bare.write k, v, :expires_in => ttl
        end
      else
        raise "Don't know how to SET with #{bare.inspect}"
      end
    end
    
    def delete(k)
      reset_if_forked_or_threaded
      if memcached?
        begin; bare.delete(k); rescue ::Memcached::NotFound; nil; end
      elsif redis?
        bare.del k
      elsif dalli? or memcached_rails? or mem_cache? or active_support_store?
        bare.delete k
      else
        raise "Don't know how to DELETE with #{bare.inspect}"
      end
    end
    
    def flush
      reset_if_forked_or_threaded
      bare.send %w{ flush flushdb flush_all clear }.detect { |flush_cmd| bare.respond_to? flush_cmd }
    end
    
    # TODO detect nils
    def exist?(k)
      reset_if_forked_or_threaded
      if memcached?
        begin; bare.get(k); true; rescue ::Memcached::NotFound; false; end
      elsif redis?
        bare.exists k
      elsif bare.respond_to?(:exist?)
        # slow because we're looking it up
        bare.exist? k
      else
        # weak because it doesn't detect keys that equal nil
        !get(k).nil?
      end
    end
    
    # TODO use native memcached increment if available
    # TODO don't reset the timer!
    def increment(k, amount)
      # reset_if_forked_or_threaded - uses get
      new_v = get(k).to_i + amount
      set k, new_v, 0
      new_v
    end
    
    def decrement(k, amount)
      # reset_if_forked_or_threaded - uses increment, which uses get
      increment k, -amount
    end
    
    # TODO don't resort to trickery like this
    def reset
      @pid = nil
    end
    
    def fetch(k, ttl, &blk)
      reset_if_forked_or_threaded
      if dalli? or mem_cache?
        bare.fetch k, ttl, &blk
      elsif active_support_store?
        bare.fetch k, { :expires_in => ttl }, &blk
      else
        if exist? k
          get k
        elsif blk
          v = blk.call
          set k, v, ttl
          v
        end
      end
    end
    
    def cas(k, ttl, &blk)
      reset_if_forked_or_threaded
      if memcached?
        begin; bare.cas(k, ttl, &blk); rescue ::Memcached::NotFound; nil; end
      elsif dalli? or memcached_rails?
        bare.cas k, ttl, &blk
      elsif blk and exist?(k)
        old_v = get k
        new_v = blk.call old_v
        set k, new_v, ttl
        new_v
      end
    end
    
    def stats
      reset_if_forked_or_threaded
      if bare.respond_to?(:stats)
        bare.stats
      else
        {}
      end
    end
    
    private
    
    def bare
      @bare ||= parent.config.client
    end
    
    def reset_if_forked_or_threaded
      if fork_detected?
        # $stderr.puts "fork detected" if ENV['CACHE_DEBUG'] == 'true'
        if dalli?
          parent.config.client.close
        elsif dalli_store?
          parent.config.client.reset
        elsif memcached? or memcached_rails?
          cloned_client = parent.config.client.clone
          parent.config.client = cloned_client
          @bare = parent.config.client
        elsif redis?
          parent.config.client.client.connect
        elsif mem_cache?
          parent.config.client.reset
        end
      elsif new_thread_detected?
        # $stderr.puts "new thread detected" if ENV['CACHE_DEBUG'] == 'true'
        if memcached? or memcached_rails?
          cloned_client = parent.config.client.clone
          parent.config.client = cloned_client
          @bare = parent.config.client
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
      answer = (defined?(::Dalli) and bare.is_a?(::Dalli::Client))
      @dalli_query = [answer]
      answer
    end
    
    def active_support_store?
      return @active_support_store_query[0] if @active_support_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache) and bare.is_a?(::ActiveSupport::Cache::Store))
      @active_support_store_query = [answer]
      answer
    end
    
    def dalli_store?
      return @dalli_store_query[0] if @dalli_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache::DalliStore) and bare.is_a?(::ActiveSupport::Cache::DalliStore))
      @dalli_store_query = [answer]
      answer
    end
    
    def memory_store?
      return @memory_store_query[0] if @memory_store_query.is_a?(::Array)
      answer = (defined?(::ActiveSupport::Cache::MemoryStore) and bare.is_a?(::ActiveSupport::Cache::MemoryStore))
      @memory_store_query = [answer]
      answer
    end
    
    def mem_cache?
      return @mem_cache_query[0] if @mem_cache_query.is_a?(::Array)
      answer = (defined?(::MemCache) and bare.is_a?(::MemCache))
      @mem_cache_query = [answer]
      answer
    end

    def memcached?
      return @memcached_query[0] if @memcached_query.is_a?(::Array)
      answer = (defined?(::Memcached) and bare.is_a?(::Memcached) and not bare.is_a?(::Memcached::Rails))
      @memcached_query = [answer]
      answer
    end
    
    def memcached_rails?
      return @memcached_rails_query[0] if @memcached_rails_query.is_a?(::Array)
      answer = (defined?(::Memcached) and bare.is_a?(::Memcached::Rails))
      @memcached_rails_query = [answer]
      answer
    end
    
    def redis?
      return @redis_query[0] if @redis_query.is_a?(::Array)
      answer = (defined?(::Redis) and bare.is_a?(::Redis))
      @redis_query = [answer]
      answer
    end
  end
end
