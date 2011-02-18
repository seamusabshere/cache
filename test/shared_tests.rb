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
    assert_equal 'world', @cache.get('hello')
    @cache.flush
    assert_equal nil, @cache.get('hello')
  end
end
