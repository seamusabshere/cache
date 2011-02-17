require 'helper'

# the famous memcache-client
require 'memcache'

class TestMemcacheStorage < Test::Unit::TestCase
  def setup
    super
    client = MemCache.new ['localhost:11211']
    client.flush_all
    Cache.config.client = client
  end
    
  include SharedTests
end
