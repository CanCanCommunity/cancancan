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

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'rails', '~> 3.0.20'
  s.add_development_dependency 'supermodel', '~> 0.1.6'
  s.add_development_dependency 'appraisal', '>= 1.0.0.beta3'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
