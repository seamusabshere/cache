require 'helper'

require 'memcached'

class TestMemcachedStorage < Test::Unit::TestCase
  def setup
    super
    client = Memcached.new 'localhost:11211'
    client.flush
    Cache.config.client = client
  end
    
  include SharedTests
end
