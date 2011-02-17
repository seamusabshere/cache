require 'helper'

if ENV['REDIS_URL']
  require 'redis'
  require 'uri'

  class TestRedisStorage < Test::Unit::TestCase
    def setup
      super
      uri = URI.parse(ENV["REDIS_URL"])
      client = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      client.flushdb
      Cache.config.client = client
    end
    
    include SharedTests
  end
end
