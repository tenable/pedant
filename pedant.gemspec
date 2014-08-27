# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

require 'pedant/version'

Gem::Specification.new do |s|
  s.name        = 'nasl-pedant'
  s.version     = Pedant::VERSION
  s.license     = 'BSD'
  s.homepage    = 'http://github.com/tenable/pedant'
  s.summary     = 'A framework for the Nessus Attack Scripting Language.'
  s.description = 'A static analysis framework for the Nessus Attack Scripting Language.'

  s.authors     = ['Mak Kolybabi', 'Alex Weber', 'Jacob Hammack']
  s.email       = ['mak@kolybabi.com', 'aweber@tenable.com', 'jhammack@tenable.com']

  s.rubyforge_project = 'nasl-pedant'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '~> 0'

  s.add_runtime_dependency 'rainbow', '=2.0.0'
  s.add_runtime_dependency 'nasl', '~> 0.1', '>= 0.1.1'
end
