class Cache::Wrapper
  class << self
    def wrap(metal)
      metal_class = metal.class.name.delete('::') # Memcached::Rails -> 'MemcachedRails'
      require "cache/wrapper/#{metal_class.underscore}"
      const_get(metal_class).new metal
    end
  end

  def initialize(metal)
    @pid = ::Process.pid
    @metal = metal
  end

  def handle_fork
    if ::Process.pid != @pid
      @pid = ::Process.pid
      after_fork
    end
  end

  def after_fork
    # nothing
  end

  def get(k)
    handle_fork
    _get k
  end

  def get_multi(ks)
    handle_fork
    _get_multi ks
  end

  def set(k, v, ttl)
    handle_fork
    _set k, v, ttl
  end

  def delete(k)
    handle_fork
    _delete k
  end

  def flush
    handle_fork
    _flush
  end

  # TODO detect nils
  def exist?(k)
    handle_fork
    _exist? k
  end

  # TODO don't reset the timer!
  # synthetic
  def increment(k, amount)
    new_v = get(k).to_i + amount
    set k, new_v, 0
    new_v
  end

  # synthetic
  def decrement(k, amount)
    increment k, -amount
  end

  # synthetic
  def fetch(k, ttl, &blk)
    if exist? k
      get k
    elsif blk
      v = blk.call
      set k, v, ttl
      v
    end
  end

  # synthetic
  def cas(k, ttl, &blk)
    if blk and exist?(k)
      old_v = get k
      new_v = blk.call old_v
      set k, new_v, ttl
      new_v
    end
  end

  def stats
    handle_fork
    _stats
  end
end
