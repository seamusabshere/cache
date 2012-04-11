require 'helper'
require 'tmpdir'
require 'fileutils'

require 'active_support/all'
require 'active_support/cache/file_store'

class TestActiveSupportCacheFileStore < Test::Unit::TestCase
  def raw_client
    tmpdir = File.join(Dir.tmpdir, "Cache-TestActiveSupportCacheFileStore-#{rand(1e11)}")
    FileUtils.mkdir_p tmpdir
    ActiveSupport::Cache::FileStore.new tmpdir
  end
    
  include SharedTests
end
