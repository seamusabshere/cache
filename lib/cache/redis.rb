module Cache::Redis
  def after_fork
    @metal.quit
  end
  
  def _get(k)
    if cached_v = @metal.get(k) and cached_v.is_a?(::String)
      ::Marshal.load cached_v
    end
  end

  def _get_multi(ks)
    ks.inject({}) do |memo, k|
      if v = _get(k)
        memo[k] = v
      end
      memo
    end
  end

  def _set(k, v, ttl)
    if ttl == 0
      @metal.set k, ::Marshal.dump(v)
    else
      @metal.setex k, ttl, ::Marshal.dump(v)
    end
  end

  def _delete(k)
    @metal.del k
  end

  def _flush
    @metal.flushdb
  end

  def _exist?(k)
    @metal.exists k
  end

  def _stats
    @metal.info
  end
end
