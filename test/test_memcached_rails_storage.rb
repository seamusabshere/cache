require 'helper'

require 'memcached'

class TestMemcachedRailsStorage < Test::Unit::TestCase
  def setup
    @client = Memcached::Rails.new 'localhost:11211'
    super
  end
    
  include SharedTests
  
  def get_bare_client_id
    @cache.storage.send(:bare_client).object_id
  end
  
  def test_treats_as_not_thread_safe
    # make sure bare client is initialized
    @cache.get 'hi'
    
    # get the main thread's bare client
    main_thread_bare_client_id = get_bare_client_id
    
    # sanity check that it's not changing every time
    @cache.get 'hi'
    assert_equal main_thread_bare_client_id, get_bare_client_id
    
    # create a new thread and get its bare client
    new_thread_bare_client_id = Thread.new { @cache.get 'hi'; get_bare_client_id }.value
    
    # make sure the bare client was reinitialized
    assert(main_thread_bare_client_id != new_thread_bare_client_id)
  end
  
  def test_treats_as_not_fork_safe
    # make sure bare client is initialized
    @cache.get 'hi'
    
    # get the main process's bare client
    parent_process_bare_client_id = get_bare_client_id
    
    # sanity check that it's not changing every time
    @cache.get 'hi'
    assert_equal parent_process_bare_client_id, get_bare_client_id
    
    # fork a new process
    pid = Kernel.fork do
      @cache.get 'hi'
      raise "Didn't split!" if parent_process_bare_client_id == get_bare_client_id
    end
    Process.wait pid
    
    # make sure it didn't raise
    assert $?.success?
  end
end
