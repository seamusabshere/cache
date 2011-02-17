module SharedTests
  def test_get
    assert_equal nil, Cache.get('hello')
    Cache.set 'hello', 'world'
    assert_equal 'world', Cache.get('hello')
  end
  
  def test_set
    assert_nothing_raised do
      Cache.set 'hello', 'world'
    end
  end
  
  def test_set_with_ttl
    Cache.set 'hello', 'world', 1
    assert_equal 'world', Cache.get('hello')
    sleep 2
    assert_equal nil, Cache.get('hello')
  end
  
  def test_set_with_zero_ttl_meaning_eternal
    Cache.set 'hello', 'world', 0
    assert_equal 'world', Cache.get('hello')
    sleep 1
    assert_equal 'world', Cache.get('hello')
  end
  
  def test_delete
    Cache.set 'hello', 'world'
    assert_equal 'world', Cache.get('hello')
    Cache.delete 'hello'
    assert_equal nil, Cache.get('hello')
  end
  
  def test_flush
    Cache.set 'hello', 'world'
    assert_equal 'world', Cache.get('hello')
    Cache.flush
    assert_equal nil, Cache.get('hello')
  end
end
