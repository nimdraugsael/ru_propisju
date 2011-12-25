require 'rubygems'
require 'jeweler'
require './lib/ru_propisju'

Jeweler::Tasks.new do |gem|
  gem.version = RuPropisju::VERSION
  gem.name = "ru_propisju"
  gem.summary = "Cумма прописью"
  gem.email = "'alfuken@me.com'"
  gem.homepage = "http://github.com/alfuken/ru_propisju"
  gem.authors = ["Julik Tarkhanov", 'Bohdan Shchepanskyy']
  gem.license = 'MIT'
  
  # Do not package invisibles
  gem.files.exclude ".*"
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
desc "Run all tests"
Rake::TestTask.new("test") do |t|
  t.libs << "test"
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
end

task :default => [ :test ]
