require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  ENV['RACK_ENV'] = 'test'
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end