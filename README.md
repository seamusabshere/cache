# cache

A unified cache handling interface, inspired by libraries like [ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html), Perl's [Cache::Cache](http://cpan.uwinnipeg.ca/module/Cache::Cache), and [CHI](http://cpan.uwinnipeg.ca/module/CHI).

## Supported methods

It will translate these methods to whatever Redis, Memcached, etc. client you're using:

    @cache.get 'hello'
    @cache.set 'hello', 'world', 5.minutes
    @cache.delete 'hello'
    @cache.flush
    @cache.exist? 'hello'
    @cache.reset
    @cache.fetch 'hello' { 'world' }
    @cache.cas 'hello' { |current| 'world' }
    @cache.increment 'high-fives'
    @cache.decrement 'high-fives'

Also provided for Rails compatibility:

    @cache.write 'hello', 'world', :expires_in => 5.minutes
    @cache.read 'hello'
    @cache.clear
    @cache.compare_and_swap
    @cache.read_multi 'hello', 'privyet', 'hallo'

## Rationale

I wanted a common interface to a bunch of great Ruby cache clients so I can develop gems (lock_method, cache_method) that accept any of them.

* I'm tired of rescuing from Memcached::NotFound
* I'm tired of forgetting whether it's :expires_in or :ttl
* I don't know why we ever started using read/write instead of get/set.
* I don't like how you have to manually handle after_fork for Redis, Memcached, etc.
* I don't know why Memcached::Rails isn't implemented as an ActiveRecord::Cache::Store (Dalli did it just fine!)
* Why are you asking me about :raw or whatever? Just marshal it

## How you might use it

<table>
  <tr>
    <th>&nbsp;</th>
    <th><a href="https://github.com/fauna/memcached">Super-fast memcached</a></th>
    <th><a href="https://github.com/mperham/dalli">Pure Ruby memcached</a> (works on <a href="http://devcenter.heroku.com/articles/memcache">Heroku</a>)</th>
    <th><a href="https://redistogo.com/">Redis</a></th>
  </tr>
  <tr>
    <td><a href="http://guides.rubyonrails.org/caching_with_rails.html#cache-stores">Rails</a></td>
    <td><pre>config.cache_store = Cache.wrap(Memcached.new)</pre></td>
    <td><pre>config.cache_store = Cache.wrap(Dalli::Client.new)</pre></td>
    <td><pre>config.cache_store = Cache.wrap(Redis.new)</pre></td>
  </tr>
  <tr>
    <td><a href="https://github.com/seamusabshere/cache_method">CacheMethod</a> (already uses Cache internally)</td>
    <td><pre>CacheMethod.config.storage = Memcached.new</pre></td>
    <td><pre>CacheMethod.config.storage = Dalli::Client.new</pre></td>
    <td><pre>CacheMethod.config.storage = Redis.new</pre></td>
  </tr>
  <tr>
    <td><a href="https://github.com/seamusabshere/lock_method">LockMethod</a> (already uses Cache internally)</td>
    <td><pre>LockMethod.config.storage = Memcached.new</pre></td>
    <td><pre>LockMethod.config.storage = Dalli::Client.new</pre></td>
    <td><pre>LockMethod.config.storage = Redis.new</pre></td>
  </tr>
  <tr>
    <td>Your own library</td>
    <td>
<pre>
# Accept any client, let Cache take care of it
def cache=(raw_client)
  @cache = Cache.wrap(raw_client)
end
</pre>
    </td>
    <td>
<pre>
# Accept any client, let Cache take care of it
def cache=(raw_client)
  @cache = Cache.wrap(raw_client)
end
</pre>
    </td>
    <td>
<pre>
# Accept any client, let Cache take care of it
def cache=(raw_client)
  @cache = Cache.wrap(raw_client)
end
</pre>
    </td>
  </tr>
</table>

## Forking/threading

When you use a Cache object to wrap Memcached or Redis, you don't have to worry about forking or threading.

For example, you don't have to set up unicorn or PhusionPassenger's <tt>after_fork</tt>.

## TTL

0 means don't expire.

## Other examples

It defaults to an in-process memory store:

    @cache = Cache.new
    @cache.set 'hello'
    @cache.get 'hello', 'world'

You can specify a more useful cache client:

    require 'memcached' # a really fast memcached client gem
    require 'cache'     # this gem, which provides a standard interface
    raw_client = Memcached.new '127.0.0.1:11211'
    @cache = Cache.wrap(raw_client)

or

    require 'redis'     # the redis key-value store
    require 'cache'     # this gem, which provides a standard interface
    raw_client = Redis.new
    @cache = Cache.wrap(raw_client)

or

    require 'dalli'     # the dalli memcached client used by heroku
    require 'cache'     # this gem, which provides a standard interface
    raw_client = Dalli::Client.new
    @cache = Cache.wrap(raw_client)

Don't know why you would ever want to do this:

    # Piggyback off the default rails cache
    @cache = Cache.wrap(Rails.cache)

## Supported clients

Supported memcached clients:

* [memcached](https://github.com/fauna/memcached) (super fast!)
* [dalli](https://github.com/mperham/dalli) (pure ruby, recommended if you're on heroku)
* [memcache-client](https://github.com/mperham/memcache-client) (not recommended. the one that comes with Rails.)

Supported Redis clients:

* [redis](https://github.com/ezmobius/redis-rb)

## Copyright

Copyright 2011 Seamus Abshere
