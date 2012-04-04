require 'helper'

require 'memcached'
require 'active_support/cache'
require 'active_support/cache/memory_store'

class TestRailsCacheStorage < Test::Unit::TestCase
  def setup
    eval %{
      module ::Rails
        def self.cache
          @cache || Memcached::Rails.new('localhost:11211', :support_cas => true)
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
    assert_equal Memcached::Rails, Cache.new.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
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
    assert_equal ActiveSupport::Cache::MemoryStore, Rails.cache.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end

  def test_explicitly_set
    c = Cache.new(Rails.cache)
    assert_equal Memcached::Rails, c.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end

  # these behave strangely because they resolve the value of Rails.cache (e.g., Memcached::Rails) before returning
  def test_silly_self_reference
    Rails.cache = Cache.new(Rails.cache)
    assert_equal Memcached::Rails, Rails.cache.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end

  def test_self_reference_twice
    Rails.cache = Cache.new(Cache.new)
    assert_equal Memcached::Rails, Rails.cache.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end
  
  def test_self_reference_with_wrap
    Rails.cache = Cache.wrap(Cache.new)
    assert_equal Memcached::Rails, Rails.cache.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end
  
  def test_self_reference_with_absurd_wrapping
    Rails.cache = Cache.new(Cache.wrap(Cache.new))
    assert_equal Memcached::Rails, Rails.cache.instance_variable_get(:@wrapper).instance_variable_get(:@metal).class
  end
  #--
end
