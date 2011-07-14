require 'helper'

require 'memcached'

class TestMemcachedBinaryStorage < Test::Unit::TestCase
  def raw_client
    Memcached.new 'localhost:11211', :support_cas => true, :binary => true
  end
    
  include SharedTests
end
