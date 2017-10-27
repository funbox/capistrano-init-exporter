require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks
Bundler.setup(:default, :development)
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec
