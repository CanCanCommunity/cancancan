require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Run Rubocop'
RuboCop::RakeTask.new

desc 'Run RSpec'
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

task default: [:rubocop, :spec]
