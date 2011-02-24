require 'helper'

require 'active_support/cache'
require 'active_support/cache/memory_store'

class TestMemoryStoreStorage < Test::Unit::TestCase
  def raw_client
    ::ActiveSupport::Cache::MemoryStore.new
  end
  
  def test_query
    assert @cache.storage.send(:memory_store?)
  end
    
  include SharedTests
end
