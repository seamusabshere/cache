class Cache::Wrapper::Redis < Cache::Wrapper
  def _get(k)
    if cached_v = @metal.get(k) and cached_v.is_a?(::String)
      ::Marshal.load cached_v
    end
  end

  def _get_multi(ks)
    ks.inject({}) do |memo, k|
      memo[k] = @metal.get(k) if @metal.exist?(k)
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
    @metal.flush
  end

  def _exist?(k)
    @metal.exists k
  end

  def _stats
    @metal.stats
  end
end
