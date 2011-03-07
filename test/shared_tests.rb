module SharedTests
  def test_get
    assert_equal nil, @cache.get('hello')
    @cache.set 'hello', 'world'
    assert_equal 'world', @cache.get('hello')
  end
  
  def test_set
    assert_nothing_raised do
      @cache.set 'hello', 'world'
    end
  end
  
  def test_set_with_ttl
    @cache.set 'hello', 'world', 1
    assert_equal 'world', @cache.get('hello')
    sleep 2
    assert_equal nil, @cache.get('hello')
  end
  
  def test_set_with_zero_ttl_meaning_eternal
    @cache.set 'hello', 'world', 0
    assert_equal 'world', @cache.get('hello')
    sleep 1
    assert_equal 'world', @cache.get('hello')
  end
  
  def test_delete
    @cache.set 'hello', 'world'
    assert_equal 'world', @cache.get('hello')
    @cache.delete 'hello'
    assert_equal nil, @cache.get('hello')
  end
  
  def test_flush
    @cache.set 'hello', 'world'
    assert @cache.exist?('hello')
    @cache.flush
    assert !@cache.exist?('hello')
  end
  
  def test_exist
    assert !@cache.exist?('hello')
    @cache.set 'hello', 'world'
    assert @cache.exist?('hello')
  end
  
  def test_exist_key_with_nil_value
    assert !@cache.exist?('hello')
    @cache.set 'hello', nil
    assert @cache.exist?('hello')
  end

  def test_stats
    assert_nothing_raised do
      @cache.stats
    end
  end

  def test_reset
    @cache.set 'hello', 'world'
    assert @cache.exist?('hello')
    @cache.reset
    # still there!
    assert @cache.exist?('hello')
  end
  
  def test_fetch
    assert_equal nil, @cache.fetch('hello')
    assert_equal 'world', @cache.fetch('hello') { 'world' }
  end
  
  def test_fetch_with_expires_in
    assert_equal 'world', @cache.fetch('hello', :expires_in => 5) { 'world' }
  end
  
  def test_fetch_with_expires_in_stringified
    assert_equal 'world', @cache.fetch('hello', 'expires_in' => 5) { 'world' }
  end
  
  def test_fetch_with_ignored_options
    assert_equal 'world', @cache.fetch('hello', :foo => 'bar') { 'world' }
  end
  
  def test_cas
    toggle = lambda do |current|
      current == 'on' ? 'off' : 'on'
    end
    
    @cache.set 'lights', 'on'
    assert_equal 'on', @cache.get('lights')
    @cache.cas 'lights', &toggle
    assert_equal 'off', @cache.get('lights')
    @cache.cas 'lights', &toggle
    assert_equal 'on', @cache.get('lights')
    @cache.cas 'lights', &toggle
    assert_equal 'off', @cache.get('lights')
  end
  
  def test_write
    @cache.write 'hello', 'world'
    assert_equal 'world', @cache.get('hello')
  end
  
  def test_write_with_expires_in
    @cache.write 'hello', 'world', :expires_in => 1
    assert_equal 'world', @cache.get('hello')
    sleep 2
    assert_equal nil, @cache.get('hello')
  end

  def test_write_with_ignored_options
    @cache.write 'hello', 'world', :foobar => 'bazboo'
    assert_equal 'world', @cache.get('hello')
  end

  def test_read
    @cache.set 'hello', 'world'
    assert_equal 'world', @cache.read('hello')
  end
  
  def test_increment
    assert !@cache.exist?('high-fives')
    @cache.increment 'high-fives'
    assert_equal 1, @cache.get('high-fives')
    @cache.increment 'high-fives'
    assert_equal 2, @cache.get('high-fives')
  end
  
  def test_decrement
    assert !@cache.exist?('high-fives')
    @cache.decrement 'high-fives'
    assert_equal -1, @cache.get('high-fives')
    @cache.decrement 'high-fives'
    assert_equal -2, @cache.get('high-fives')
  end
  
  def test_get_multi
    @cache.set 'hello', 'world'
    @cache.set 'privyet', 'mir'
    assert_equal({ 'hello' => 'world', 'privyet' => 'mir'}, @cache.get_multi('hello', 'privyet', 'yoyoyo'))
  end
end
