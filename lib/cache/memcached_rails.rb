require 'cache/memcached'
module Cache::MemcachedRails
  def self.extended(base)
    base.extend Cache::Memcached
    base.extend Override
  end

  module Override
    def _exist?(k)
      thread_metal.exist? k
      # !get(k).nil?
    end

    def _get(k)
      thread_metal.get k
    end

    def _get_multi(ks)
      thread_metal.get_multi ks
    end

    def _delete(k)
      thread_metal.delete k
    end

    # native
    def cas(k, ttl = nil, &blk)
      handle_fork
      thread_metal.cas k, extract_ttl(ttl), &blk
    end
    # --
  end
end
