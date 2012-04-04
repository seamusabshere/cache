require 'cache/wrapper/memcached'
class Cache::Wrapper::MemcachedRails < Cache::Wrapper::Memcached
  def _get(k)
    thread_metal.get k
  end

  def _get_multi(ks)
    thread_metal.get_multi ks
  end

  def _delete(k)
    thread_metal.delete k
  end

  def _flush
    thread_metal.flush
  end

  def _exist?(k)
    thread_metal.exist? k
    # !get(k).nil?
  end

  # native
  def cas(k, ttl, &blk)
    handle_fork
    thread_metal.cas k, ttl, &blk
  end
  # --
end
