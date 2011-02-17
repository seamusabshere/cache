require 'helper'

require 'dalli'

class TestDalliStorage < Test::Unit::TestCase
  def setup
    super
    client = Dalli::Client.new ['localhost:11211']
    client.flush
    Cache.config.client = client
  end
    
  include SharedTests
end
