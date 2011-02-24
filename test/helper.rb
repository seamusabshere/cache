require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache'

require 'shared_tests'

class Test::Unit::TestCase
  def setup
    @cache = Cache.new raw_client
    @cache.flush
  end
end

ENV['CACHE_DEBUG'] = 'true'