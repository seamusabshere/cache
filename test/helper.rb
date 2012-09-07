require 'rubygems'
require 'bundler/setup'
require 'test/unit'

require 'cache'

require 'shared_tests'

class Test::Unit::TestCase
  def setup
    @cache = Cache.wrap raw_client
    @cache.flush
  end
end

ENV['CACHE_DEBUG'] = 'true'