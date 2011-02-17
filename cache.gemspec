# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cache/version"

Gem::Specification.new do |s|
  s.name        = "cache"
  s.version     = Cache::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Seamus Abshere"]
  s.email       = ["seamus@abshere.net"]
  s.homepage    = "https://github.com/seamusabshere/cache"
  s.summary     = %q{Wraps memcached, redis, memcache-client, dalli and handles their weirdnesses, including forking}
  s.description = %q{A unified cache handling interface, inspired by (but simpler than) Perl's Cache::Cache}

  s.rubyforge_project = "cache"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'test-unit'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'dalli'
  s.add_development_dependency 'activesupport', '>=2.3.4' # for DalliStore
  s.add_development_dependency 'i18n' # activesupport
  s.add_development_dependency 'memcached'
  s.add_development_dependency 'memcache-client'
end
