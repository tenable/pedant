# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pedant/version"

Gem::Specification.new do |s|
  s.name        = "pedant"
  s.version     = Pedant::VERSION
  s.authors     = ["Mak Kolybabi"]
  s.email       = ["mak@kolybabi.com"]
  s.homepage    = "http://github.com/mogigoma/pedant"
  s.summary     = %q{A static analysis framework for NASL.}

  s.rubyforge_project = "pedant"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'

  s.add_runtime_dependency 'rainbow'
  s.add_runtime_dependency 'nasl'
end
