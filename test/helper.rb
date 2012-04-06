require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache'

if ::Bundler.definition.specs['ruby-debug19'].first or ::Bundler.definition.specs['ruby-debug'].first
  require 'ruby-debug'
end

require 'shared_tests'

class Test::Unit::TestCase
  def setup
    @cache = Cache.wrap raw_client
    @cache.flush
  end
end

ENV['CACHE_DEBUG'] = 'true'