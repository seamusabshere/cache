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
