require 'cache/wrapper/active_support_cache_store'
class Cache::Wrapper::ActiveSupportCacheMemoryStore < Cache::Wrapper::ActiveSupportCacheStore
  def _stats
    {}
  end
end
