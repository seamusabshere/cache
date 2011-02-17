require 'helper'

require 'dalli'
require 'active_support/all'
require 'active_support/cache/dalli_store'

class TestDalliStoreStorage < Test::Unit::TestCase
  def setup
    super
    client = ActiveSupport::Cache::DalliStore.new ['localhost:11211']
    client.clear
    Cache.config.client = client
  end
    
  include SharedTests
end
