require 'cache/active_support_cache_store'
module Cache::ActiveSupportCacheDalliStore
  def self.extended(base)
    base.extend Cache::ActiveSupportCacheStore
  end

  def after_fork
    @metal.reset
  end

  def _stats
    @metal.stats
  end
end
