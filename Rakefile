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

task :tag_and_bag do
	system "git tag -a v#{Pedant::VERSION} -m 'version #{Pedant::VERSION}'"
	system "git push --tags"
	system "git checkout master"
	#system "git merge #{Pedant::VERSION}"
	system "git push"
end

task :release => [:tag_and_bag, :build] do
 	system "gem push #{Pedant::APP_NAME}-#{Pedant::VERSION}.gem"
end

task :default => :compile
