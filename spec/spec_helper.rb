require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'matchers'
require 'cancan/matchers'
require 'i18n'

# I8n setting to fix deprecation.
# Seting it to true will skip the locale validation (Rails 3 behavior).
# Seting it to false will raise an error if an invalid locale is passed (Rails 4 behavior).
I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


  end
end

# Add support to load paths
$:.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
