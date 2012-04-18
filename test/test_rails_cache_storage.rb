require 'helper'

require 'dalli'
require 'active_support/cache'
require 'active_support/cache/memory_store'

class TestRailsCacheStorage < Test::Unit::TestCase
  def setup
    eval %{
      module ::Rails
        def self.cache
          @cache || ActiveSupport::Cache::DalliStore.new(['localhost:11211'])
        end
        def self.cache=(foo)
          @cache = foo
        end
      end
    }
  end
  
  def teardown
    Object.send(:remove_const, :Rails)  
  end
  
  def test_defaults_to_rails_cache
    assert_equal ActiveSupport::Cache::DalliStore, Cache.new.metal.class
  end
    
  def test_helpful_default
    eval %{
      module ::Rails
        def self.cache
          @cache
        end
      end
    }
    Rails.cache = Cache.new
    assert_equal ActiveSupport::Cache::MemoryStore, Rails.cache.metal.class
  end

  def test_explicitly_set
    c = Cache.new(Rails.cache)
    assert_equal ActiveSupport::Cache::DalliStore, c.metal.class
  end

  # these behave strangely because they resolve the value of Rails.cache (e.g., ActiveSupport::Cache::DalliStore) before returning
  def test_silly_self_reference
    Rails.cache = Cache.new(Rails.cache)
    assert_equal ActiveSupport::Cache::DalliStore, Rails.cache.metal.class
  end

  def test_self_reference_twice
    Rails.cache = Cache.new(Cache.new)
    assert_equal ActiveSupport::Cache::DalliStore, Rails.cache.metal.class
  end
  
  def test_self_reference_with_wrap
    Rails.cache = Cache.wrap(Cache.new)
    assert_equal ActiveSupport::Cache::DalliStore, Rails.cache.metal.class
  end
  
  def test_self_reference_with_absurd_wrapping
    Rails.cache = Cache.new(Cache.wrap(Cache.new))
    assert_equal ActiveSupport::Cache::DalliStore, Rails.cache.metal.class
  end
  #--
end
