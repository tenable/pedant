# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'pedant/version'

Gem::Specification.new do |s|
  s.name        = 'nasl-pedant'
  s.version     = Pedant::VERSION
  s.license     = 'BSD'
  s.homepage    = 'http://github.com/tenable/pedant'
  s.summary     = 'A static analysis framework for the Nessus Attack Scripting Language.'

  s.authors     = ['Mak Kolybabi']
  s.email       = ['mak@kolybabi.com']

  s.rubyforge_project = 'nasl-pedant'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake'

  s.add_runtime_dependency 'rainbow'
  s.add_runtime_dependency 'nasl', '>= 0.0.7'
end
