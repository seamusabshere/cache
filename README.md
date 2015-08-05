# ymmv

Update August 2015: If you are looking for locking and caching methods, [lock_and_cache](https://github.com/seamusabshere/lock_and_cache) is a simpler alternative that is redis-only.

# cache

Wraps memcached, redis, memcache-client, dalli and handles their weirdnesses, including forking.

Aims to let other libraries be cache-agnostic in return for a performance hit.

## Real world usage

Used by [lock_method](https://github.com/seamusabshere/lock_method) and [cache_method](https://github.com/seamusabshere/cache_method) so that you can use them with memcached, redis, etc.

In production use at [carbon.brighterplanet.com](http://carbon.brighterplanet.com) and [data.brighterplanet.com](http://data.brighterplanet.com).

## Quick example

    require 'memcached' # a really fast memcached client gem by Evan Weaver, one of the lead engineers at Twitter
    require 'cache'     # this gem, which wraps the client to provide a standard interface
    
    client = Memcached.new('127.0.0.1:11211', :binary_protocol => true)
    @cache = Cache.wrap(client)
    
    # don't worry, even though it's memcached gem, this won't raise Memcached::NotFound
    @cache.get('hello')
    
    # fetch is not provided by the memcached gem, the wrapper adds it
    @cache.fetch('hello') { 'world' }
    
    # don't worry, the wrapper will automatically clone the Memcached object after forking (or threading for that matter)
    Kernel.fork { @cache.get('hello') }

If you can't use the memcached gem (because you're on heroku, for example) then just wrap a dalli or a redis client. You still get exactly the same interface.

## Rationale

I wanted a common interface to a bunch of great Ruby cache clients so I can develop gems ([lock_method](https://github.com/seamusabshere/lock_method), [cache_method](https://github.com/seamusabshere/cache_method)) that accept any of them.

* I'm tired of rescuing from Memcached::NotFound
* I'm tired of forgetting whether it's :expires_in or :ttl
* I don't know why we ever started using read/write instead of get/set.
* I don't like how you have to manually handle after_fork for Redis, Memcached, etc.
* I don't know why Memcached::Rails doesn't act like a ActiveRecord::Cache::Store
* Why are you asking me about :raw or whatever? Just marshal it

## Speed

It's more than 50% slower than raw [Memcached](https://github.com/evan/memcached) and about the same as raw [Dalli](https://github.com/mperham/dalli)

    # raw dalli versus wrapped

    set: cache:dalli:bin                   2.150000   0.840000   2.990000 (  3.752008) <- Cache.wrap(Dalli::Client.new)
    set: dalli:bin                         2.120000   0.830000   2.950000 (  3.734024) <- Dalli::Client.new

    get: cache:dalli:bin                   2.040000   0.910000   2.950000 (  3.646148)
    get: dalli:bin                         2.040000   0.900000   2.940000 (  3.632840)

    delete: cache:dalli:bin                1.830000   0.880000   2.710000 (  3.381917)
    delete: dalli:bin                      1.790000   0.880000   2.670000 (  3.327514)

    get-missing: cache:dalli:bin           1.780000   0.880000   2.660000 (  3.344041)
    get-missing: dalli:bin                 1.760000   0.880000   2.640000 (  3.337539)

    set-large: cache:dalli:bin             2.750000   0.880000   3.630000 (  4.474265)
    set-large: dalli:bin                   2.720000   0.870000   3.590000 (  4.436163)

    get-large: cache:dalli:bin             2.420000   0.990000   3.410000 (  4.135326)
    get-large: dalli:bin                   2.410000   0.990000   3.400000 (  4.119832)

    # raw memcached versus wrapped

    set: cache:libm:bin                    0.860000   0.640000   1.500000 (  3.033145) <- Cache.wrap(Memcached.new(:binary_protocol => true))
    set: libm:bin                          0.200000   0.480000   0.680000 (  1.907099) <- Memcached.new(:binary_protocol => true)

    get: cache:libm:bin                    0.800000   0.680000   1.480000 (  2.700458)
    get: libm:bin                          0.260000   0.660000   0.920000 (  1.974025)

    delete: cache:libm:bin                 1.000000   0.600000   1.600000 (  2.968057)
    delete: libm:bin                       0.600000   0.560000   1.160000 (  2.375070)

    get-missing: cache:libm:bin            0.980000   0.800000   1.780000 (  2.850947)
    get-missing: libm:bin                  0.640000   0.710000   1.350000 (  2.520733)

    set-large: cache:libm:bin              1.220000   0.590000   1.810000 (  3.404739)
    set-large: libm:bin                    0.230000   0.520000   0.750000 (  2.111738)

    get-large: cache:libm:bin              3.780000   0.870000   4.650000 (  6.073208)
    get-large: libm:bin                    0.340000   0.830000   1.170000 (  2.304408)

Thanks to https://github.com/evan/memcached/blob/master/test/profile/benchmark.rb

So: hopefully it makes it easier to get started with caching and hit the low-hanging fruit. Then you can move on to a raw client!

## Features

### Forking/threading

When you use a Cache object to wrap Memcached or Redis, you don't have to worry about forking or threading.

For example, you don't have to set up unicorn or PhusionPassenger's <tt>after_fork</tt>.

### TTL

0 means don't expire.

The default ttl is 60 seconds.

### Marshalling

Everything gets marshalled. No option to turn it into "raw" mode. If you need that kind of control, please submit a patch or just use one of the other gems directly.

### Methods

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
    @cache.get_multi 'hello', 'privyet', 'hallo'

Also provided for Rails compatibility:

    @cache.write 'hello', 'world', :expires_in => 5.minutes
    @cache.read 'hello'
    @cache.clear
    @cache.compare_and_swap
    @cache.read_multi 'hello', 'privyet', 'hallo'

## Supported clients

Supported memcached clients:

* [memcached](https://github.com/fauna/memcached) (native C extensions, super fast!)
* [dalli](https://github.com/mperham/dalli) (pure ruby, recommended if you're on heroku)
* [memcache-client](https://github.com/mperham/memcache-client) (not recommended. the one that comes with Rails.)

Supported Redis clients:

* [redis](https://github.com/ezmobius/redis-rb)

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
</table>

## Other examples

It defaults to an in-process memory store:

    @cache = Cache.new
    @cache.set 'hello', 'world'
    @cache.get 'hello'

You can specify a more useful cache client:

    require 'redis'     # the redis key-value store
    require 'cache'     # this gem, which provides a standard interface
    raw_client = Redis.new
    @cache = Cache.wrap(raw_client)

or

    require 'dalli'     # the dalli memcached client used by heroku
    require 'cache'     # this gem, which provides a standard interface
    raw_client = Dalli::Client.new
    @cache = Cache.wrap(raw_client)

Or you could piggyback off the default rails cache:

    @cache = Cache.wrap(Rails.cache)

## Copyright

Copyright 2011 Seamus Abshere
