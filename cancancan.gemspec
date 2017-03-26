# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cancan/version'

Gem::Specification.new do |s|
  s.name        = 'cancancan'
  s.version     = CanCan::VERSION
  s.authors     = ['Alessandro Rodi (Renuo AG)', 'Bryan Rite', 'Ryan Bates', 'Richard Wilson']
  s.email       = 'alessandro.rodi@renuo.ch'
  s.homepage    = 'https://github.com/CanCanCommunity/cancancan'
  s.summary     = 'Simple authorization solution for Rails.'
  s.description = 'Simple authorization solution for Rails. All permissions are stored in a single location.'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'

  s.files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files  = `git ls-files -- Appraisals {spec,features,gemfiles}/*`.split($INPUT_RECORD_SEPARATOR)
  s.executables = `git ls-files -- bin/*`.split($INPUT_RECORD_SEPARATOR).map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rubocop', '~> 0.46'
  s.add_development_dependency 'rake', '~> 10.1.1'
  s.add_development_dependency 'rspec', '~> 3.2.0'
  s.add_development_dependency 'appraisal', '>= 2.0.0'
end
