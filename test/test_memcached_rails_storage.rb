require 'helper'

require 'memcached'

class TestMemcachedRailsStorage < Test::Unit::TestCase
  def setup
    super
    client = Memcached::Rails.new 'localhost:11211'
    client.flush
    Cache.config.client = client
  end
    
  include SharedTests
end
