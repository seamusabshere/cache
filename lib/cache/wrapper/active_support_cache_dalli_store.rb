require 'cache/wrapper/active_support_cache_store'
class Cache::Wrapper::ActiveSupportCacheDalliStore < Cache::Wrapper::ActiveSupportCacheStore
  def after_fork
    @metal.reset
  end
end
