# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lexis_nexis_api/version"

Gem::Specification.new do |s|
  s.name        = "lexis_nexis_api"
  s.version     = LexisNexisApi::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jeff Emminger"]
  s.email       = ["jeff@7compass.com"]
  s.homepage    = "http://github.com/7compass/lexis_nexis_api"
  s.summary     = %q{Lexis Nexis Api gem}
  s.description = %q{}

  s.rubyforge_project = "lexis_nexis_api"

  s.add_runtime_dependency("nokogiri")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license = 'MIT'
end
