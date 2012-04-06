module Cache::Memcached
  def thread_metal
    ::Thread.current["#{@pid}/#{self.class.name}/#{object_id}/thread_metal"] ||= @metal.clone
  end

  def _get(k)
    thread_metal.get k
  rescue ::Memcached::NotFound
    # oh well
  end

  def _get_multi(ks)
    thread_metal.get ks
  end

  def _set(k, v, ttl)
    thread_metal.set k, v, ttl
  end

  def _delete(k)
    thread_metal.delete k
  rescue ::Memcached::NotFound
  end

  def _flush
    thread_metal.flush
  end

  def _exist?(k)
    thread_metal.get k
    true
  rescue ::Memcached::NotFound
    false
  end

  def _stats
    thread_metal.stats
  end

  # native
  def cas(k, ttl = nil, &blk)
    handle_fork
    thread_metal.cas k, extract_ttl(ttl), &blk
  rescue ::Memcached::NotFound
  end
  # --
end
