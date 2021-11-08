# frozen_string_literal: true

RSpec::Matchers.define :orderlessly_match do |original_string|
  match do |given_string|
    original_string.chars.sort == given_string.chars.sort
  end

  failure_message do |given_string|
    "expected \"#{given_string}\" to have the same characters as \"#{original_string}\""
  end

  failure_message_when_negated do |given_string|
    "expected \"#{given_string}\" not to have the same characters as \"#{original_string}\""
  end
end
