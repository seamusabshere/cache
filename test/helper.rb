require 'rubygems'
require 'bundler'
Bundler.setup
require 'test/unit'
# require 'ruby-debug'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'cache'

require 'shared_tests'

class Test::Unit::TestCase
end
