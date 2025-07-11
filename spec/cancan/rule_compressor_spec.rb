# frozen_string_literal: true

require 'spec_helper'

describe CanCan::RulesCompressor do
  before do
    class Blog
    end
  end

  def can(action, subject, args = nil)
    CanCan::Rule.new(true, action, subject, args, nil)
  end

  def cannot(action, subject, args = nil)
    CanCan::Rule.new(false, action, subject, args, nil)
  end

  context 'a "cannot catch_all" rule is in first position' do
    let(:rules) do
      [cannot(:read, Blog),
       can(:read, Blog)]
    end
    it 'deletes it' do
      expect(described_class.new(rules).rules_collapsed).to eq rules[1..-1]
    end
  end

  context 'a "can catch all" rule is in last position' do
    let(:rules) do
      [cannot(:read, Blog, id: 2),
       can(:read, Blog, id: 1),
       can(:read, Blog)]
    end

    it 'deletes all previous rules' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules.last]
    end
  end

  context 'a "can catch_all" rule is in front of others can rules' do
    let(:rules) do
      [can(:read, Blog, id: 1),
       can(:read, Blog),
       can(:read, Blog, id: 3),
       can(:read, Blog, author: { id: 3 }),
       cannot(:read, Blog, private: true)]
    end

    it 'deletes all previous rules and subsequent rules of the same type' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules[1], rules.last]
    end
  end

  context 'a "cannot catch_all" rule is in front of others cannot rules' do
    let(:rules) do
      [can(:read, Blog, id: 1),
       can(:read, Blog),
       can(:read, Blog, id: 3),
       cannot(:read, Blog),
       cannot(:read, Blog, private: true),
       can(:read, Blog, id: 3)]
    end

    it 'deletes all previous rules and subsequent rules of the same type' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules.last]
    end
  end

  context 'a lot of rules' do
    let(:rules) do
      [
        cannot(:read, Blog, id: 4),
        can(:read, Blog, id: 1),
        can(:read, Blog),
        can(:read, Blog, id: 3),
        cannot(:read, Blog),
        cannot(:read, Blog, private: true),
        can(:read, Blog, id: 3),
        can(:read, Blog, id: 8),
        cannot(:read, Blog, id: 5)
      ]
    end

    it 'minimizes the rules' do
      expect(described_class.new(rules).rules_collapsed).to eq rules.last(3)
    end
  end

  context 'duplicate rules' do
    let(:rules) do
      [can(:read, Blog, id: 4),
       can(:read, Blog, id: 1),
       can(:read, Blog, id: 2),
       can(:read, Blog, id: 2),
       can(:read, Blog, id: 3),
       can(:read, Blog, id: 2)]
    end

    it 'minimizes the rules, by removing duplicates' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules[0], rules[1], rules[4], rules[5]]
    end
  end

  context 'duplicates rules with cannot' do
    let(:rules) do
      [can(:read, Blog, id: 1),
       cannot(:read, Blog, id: 1)]
    end

    it 'minimizes the rules, by removing useless previous rules' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules[1]]
    end
  end

  context 'duplicates rules with cannot and can again' do
    let(:rules) do
      [can(:read, Blog, id: [1, 2]),
       cannot(:read, Blog, id: 1),
       can(:read, Blog, id: 1)]
    end

    it 'minimizes the rules, by removing useless previous rules' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules[0], rules[2]]
    end
  end

  context 'duplicates rules with 2 cannot' do
    let(:rules) do
      [can(:read, Blog),
       cannot(:read, Blog, id: 1),
       cannot(:read, Blog, id: 1)]
    end

    it 'minimizes the rules, by removing useless previous rules' do
      expect(described_class.new(rules).rules_collapsed).to eq [rules[0], rules[2]]
    end
  end

  # TODO: not supported yet
  xcontext 'merges rules' do
    let(:rules) do
      [can(:read, Blog, id: 4),
       can(:read, Blog, id: 1),
       can(:read, Blog, id: 2),
       can(:read, Blog, id: 2),
       can(:read, Blog, id: 3),
       can(:read, Blog, id: 2)]
    end

    it 'minimizes the rules, by merging them' do
      expect(described_class.new(rules).rules_collapsed).to eq [can(:read, Blog, id: [4, 1, 2, 3])]
    end
  end
end
