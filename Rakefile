$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'bundler/gem_tasks'
require 'rake'
require 'rake/clean'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/test_*.rb']
end

desc "Produce a fully-functional application."
task :compile => :test

task :build => :compile do
  system "gem build pedant.gemspec"
end

task :default => :compile
