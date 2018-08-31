require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'matchers'
require 'cancan/matchers'

# I8n setting to fix deprecation.
if defined?(I18n) && I18n.respond_to?('enforce_available_locales=')
  I18n.enforce_available_locales = false
end

# Add support to load paths
$LOAD_PATH.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SQLHelpers
end

RSpec::Matchers.define :generate_sql do |expected|
  match do |actual|
    normalized_sql(actual) == expected.gsub(/\s+/, ' ').strip
  end
  failure_message do |actual|
    "Returned sql:\n#{normalized_sql(actual)}\ninstead of:\n#{expected.gsub(/\s+/, ' ').strip}"
  end
end
