require 'helper'

require 'active_support/cache'
require 'active_support/cache/memory_store'

class TestRailsCacheStorage < Test::Unit::TestCase
  def setup
    eval %{
      module ::Rails
        def self.cache
          @cache || :deadbeef
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
    assert_equal :deadbeef, Cache.new.config.client
  end
    
  def test_helpful_default
    Rails.cache = Cache.new
    assert_equal ActiveSupport::Cache::MemoryStore, Rails.cache.config.client.class
  end

  def test_explicitly_set
    c = Cache.new(Rails.cache)
    assert_equal :deadbeef, c.config.client
  end

  def test_explicitly_set_2
    c = Cache.new
    c.config.client = Rails.cache
    assert_equal :deadbeef, c.config.client
  end

  # these behave strangely because they resolve the value of Rails.cache (e.g., :deadbeef) before returning
  def test_silly_self_reference
    Rails.cache = Cache.new(Rails.cache)
    assert_equal :deadbeef, Rails.cache.config.client
  end

  def test_self_reference_twice
    Rails.cache = Cache.new(Cache.new)
    assert_equal :deadbeef, Rails.cache.config.client
  end
  
  def test_self_reference_with_wrap
    Rails.cache = Cache.wrap(Cache.new)
    assert_equal :deadbeef, Rails.cache.config.client
  end
  
  def test_self_reference_with_absurd_wrapping
    Rails.cache = Cache.new(Cache.wrap(Cache.new))
    assert_equal :deadbeef, Rails.cache.config.client
  end
  #--
end
