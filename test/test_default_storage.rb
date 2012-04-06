require 'helper'

class TestDefaultStorage < Test::Unit::TestCase
  def raw_client
    nil
  end
  
  def test_query
    assert_equal ActiveSupport::Cache::MemoryStore, @cache.metal.class
  end
  
  def test_default
    c = Cache.new
    assert_equal ActiveSupport::Cache::MemoryStore, c.metal.class
  end
  
  def test_self_reference
    c = Cache.new(Cache.new)
    assert_equal ActiveSupport::Cache::MemoryStore, c.metal.class
  end
  
  def test_wrap_with_default
    c = Cache.wrap(Cache.new)
    assert_equal ActiveSupport::Cache::MemoryStore, c.metal.class
  end
  
  def test_absurd_wrap
    c = Cache.new(Cache.wrap(Cache.new))
    assert_equal ActiveSupport::Cache::MemoryStore, c.metal.class
  end
  
  include SharedTests
end
