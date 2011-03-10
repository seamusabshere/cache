# cache

Wraps memcached, redis, memcache-client, dalli and handles their weirdnesses, including forking.

A unified cache handling interface, inspired by libraries like [ActiveSupport::Cache::Store](http://api.rubyonrails.org/classes/ActiveSupport/Cache/Store.html), Perl's [Cache::Cache](http://cpan.uwinnipeg.ca/module/Cache::Cache), and [CHI](http://cpan.uwinnipeg.ca/module/CHI).

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
* I don't know why Memcached::Rails isn't implemented as an ActiveRecord::Cache::Store (Dalli did it just fine!)
* Why are you asking me about :raw or whatever? Just marshal it

## Real world usage

In production use at [carbon.brighterplanet.com](http://carbon.brighterplanet.com), the Brighter Planet emission estimate web service.

## Speed

It's about 50% slower than raw Memcached (if that's what you're wrapping) and barely slower at all than Dalli (if that's what you're wrapping.)

                                          user     system      total        real
    set: cache:dalli:bin                  5.710000   1.870000   7.580000 ( 10.210710)  <- Cache.wrap(Dalli::Client.new)
    set: cache:libm:bin                   1.320000   1.260000   2.580000 (  5.913591)  <- Cache.wrap(Memcached.new(:binary_protocol => true))
    set: dalli:bin                        5.350000   1.860000   7.210000 (  9.860368)  <- Dalli::Client.new
    set: libm:ascii                       0.760000   1.310000   2.070000 (  5.369027)
    set: libm:ascii:pipeline              0.280000   0.020000   0.300000 (  0.300872)
    set: libm:ascii:udp                   0.640000   0.690000   1.330000 (  3.618846)
    set: libm:bin                         0.640000   1.370000   2.010000 (  5.287203)  <- Memcached.new(:binary_protocol => true)
    set: libm:bin:buffer                  0.320000   0.170000   0.490000 (  1.238471)
    set: mclient:ascii                   11.840000   3.820000  15.660000 ( 15.933338)
    set: stash:bin                        3.420000   1.300000   4.720000 (  7.871299)

    get: cache:dalli:bin                  5.740000   2.050000   7.790000 ( 10.220809)  <- Cache.wrap(Dalli::Client.new)
    get: cache:libm:bin                   1.330000   1.260000   2.590000 (  5.789277)  <- Cache.wrap(Memcached.new(:binary_protocol => true))
    get: dalli:bin                        5.430000   2.050000   7.480000 (  9.945485)  <- Dalli::Client.new
    get: libm:ascii                       0.970000   1.290000   2.260000 (  5.421878)
    get: libm:ascii:pipeline              1.030000   1.590000   2.620000 (  5.728829)
    get: libm:ascii:udp                   0.790000   0.730000   1.520000 (  3.393461)
    get: libm:bin                         0.830000   1.330000   2.160000 (  5.362280)  <- Memcached.new(:binary_protocol => true)
    get: libm:bin:buffer                  0.900000   1.640000   2.540000 (  5.719478)
    get: mclient:ascii                   14.010000   3.860000  17.870000 ( 18.125730)
    get: stash:bin                        3.100000   1.320000   4.420000 (  7.559659)

Thanks to https://github.com/fauna/memcached/blob/master/test/profile/benchmark.rb

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
    @cache.set 'hello'
    @cache.get 'hello', 'world'

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
