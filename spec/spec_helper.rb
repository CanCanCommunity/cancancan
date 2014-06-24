require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'matchers'
require 'cancan/matchers'

# I8n setting to fix deprecation.
I18n.enforce_available_locales = false if defined? I18n

# Add support to load paths
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
