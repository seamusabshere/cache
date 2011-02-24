require 'helper'

require 'active_support/cache'
require 'active_support/cache/memory_store'

class TestDefaultStorage < Test::Unit::TestCase
  def raw_client
    nil
  end
  
  def test_query
    assert @cache.storage.send(:memory_store?)
  end
    
  include SharedTests
end
