module Cache::DalliClient
  def after_fork
    @metal.close
  end

  def _get(k)
    @metal.get k
  end

  def _get_multi(ks)
    @metal.get_multi ks
  end

  def _set(k, v, ttl)
    @metal.set k, v, ttl
  end

  def _delete(k)
    @metal.delete k
  end

  def _flush
    @metal.flush
  end

  # sux
  def _exist?(k)
    !@metal.get(k).nil?
  end

  def _stats
    @metal.stats
  end

  # native
  def fetch(k, ttl = nil, &blk)
    handle_fork
    @metal.fetch k, extract_ttl(ttl), &blk
  end

  def cas(k, ttl = nil, &blk)
    handle_fork
    @metal.cas k, extract_ttl(ttl), &blk
  end
  # --
end
