# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cache/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "cache"
  s.version     = Cache::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere","Christoph Grabo"]
  s.email       = ["seamus@abshere.net","chris@dinarrr.com"]
  s.homepage    = "https://github.com/seamusabshere/cache"
  s.summary     = %q{A unified cache handling interface inspired by libraries like ActiveSupport::Cache::Store, Perl's Cache::Cache, CHI, etc.}
  s.description = %q{Wraps memcached, redis(-namespace), memcache-client, dalli and handles their weirdnesses, including forking}

  s.rubyforge_project = "cache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'activesupport', '>=2.3.11' # for default memory store
  s.add_development_dependency 'yard'
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'redis-namespace'
  s.add_development_dependency 'dalli'
  unless RUBY_PLATFORM == 'java'
    s.add_development_dependency 'memcached'
  end
  s.add_development_dependency 'memcache-client'
  s.add_development_dependency 'rack' # for ActiveSupport::Cache::FileStore of all things
end

