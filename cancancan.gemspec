# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cancan/version'

Gem::Specification.new do |s|
  s.name        = "cancancan"
  s.version     = CanCan::VERSION
  s.authors     = ["Bryan Rite", "Ryan Bates"]
  s.email       = "bryan@bryanrite.com"
  s.homepage    = "https://github.com/CanCanCommunity/cancancan"
  s.summary     = "Simple authorization solution for Rails."
  s.description = "Continuation of the simple authorization solution for Rails which is decoupled from user roles. All permissions are stored in a single location."
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"

  s.files       = `git ls-files`.split($/)
  s.test_files  = `git ls-files -- Appraisals {spec,features,gemfiles}/*`.split($/)
  s.executables = `git ls-files -- bin/*`.split($/).map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.required_rubygems_version = ">= 1.3.4"

  s.add_development_dependency 'rspec', '~> 3.0.0.beta2'
  s.add_development_dependency 'rails', '~> 3.0.9'
  s.add_development_dependency 'supermodel', '~> 0.1.4'

  s.rubyforge_project = s.name
end
