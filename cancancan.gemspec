Gem::Specification.new do |s|
  s.name        = "cancancan"
  s.version     = "1.7.0"
  s.authors     = ["Bryan Rite", "Ryan Bates"]
  s.email       = "bryan@bryanrite.com"
  s.homepage    = "http://github.com/bryanrite/cancancan"
  s.summary     = "Simple authorization solution for Rails."
  s.description = "Continuation of the simple authorization solution for Rails which is decoupled from user roles. All permissions are stored in a single location."
  s.platform    = Gem::Platform::RUBY

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_development_dependency 'rspec', '~> 2.14'
  s.add_development_dependency 'rails', '~> 3.0.9'
  s.add_development_dependency 'supermodel', '~> 0.1.4'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
