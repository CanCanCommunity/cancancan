# frozen_string_literal: true

require 'spec_helper'
require 'ostruct' # for OpenStruct below

# Most of Rule functionality is tested in Ability specs
RSpec.describe CanCan::Rule do
  before(:each) do
    @conditions = {}
    @rule = CanCan::Rule.new(true, :read, Integer, @conditions)
  end

  it 'returns no association joins if none exist' do
    expect(@rule.associations_hash).to eq({})
  end

  it 'returns no association for joins if just attributes' do
    @conditions[:foo] = :bar
    expect(@rule.associations_hash).to eq({})
  end

  it 'returns single association for joins' do
    @conditions[:foo] = { bar: 1 }
    expect(@rule.associations_hash).to eq(foo: {})
  end

  it 'returns multiple associations for joins' do
    @conditions[:foo] = { bar: 1 }
    @conditions[:test] = { 1 => 2 }
    expect(@rule.associations_hash).to eq(foo: {}, test: {})
  end

  it 'returns nested associations for joins' do
    @conditions[:foo] = { bar: { 1 => 2 } }
    expect(@rule.associations_hash).to eq(foo: { bar: {} })
  end

  it 'returns no association joins if conditions is nil' do
    rule = CanCan::Rule.new(true, :read, Integer, nil)
    expect(rule.associations_hash).to eq({})
  end

  it 'allows nil in attribute spot for edge cases' do
    rule1 = CanCan::Rule.new(true, :action, :subject, nil, :var)
    expect(rule1.attributes).to eq []
    expect(rule1.conditions).to eq :var
    rule2 = CanCan::Rule.new(true, :action, :subject, nil, %i[foo bar])
    expect(rule2.attributes).to eq []
    expect(rule2.conditions).to eq %i[foo bar]
  end

  unless RUBY_ENGINE == 'jruby'
    describe '#inspect' do
      def count_queries(&block)
        count = 0
        counter_f = lambda { |_name, _started, _finished, _unique_id, payload|
          count += 1 unless payload[:name].in? %w[CACHE SCHEMA]
        }
        ActiveSupport::Notifications.subscribed(counter_f, 'sql.active_record', &block)
        count
      end

      before do
        ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
        ActiveRecord::Migration.verbose = false
        ActiveRecord::Schema.define do
          create_table(:watermelons) do |t|
            t.boolean :visible
          end
        end

        class Watermelon < ActiveRecord::Base
          scope :visible, -> { where(visible: true) }
        end
      end

      it 'does not evaluate the conditions when they are scopes' do
        rule = CanCan::Rule.new(true, :read, Watermelon, Watermelon.visible, {}, {})
        count = count_queries { rule.inspect }
        expect(count).to eq 0
      end

      it 'displays the rule correctly when it is constructed through sql array' do
        rule = CanCan::Rule.new(true, :read, Watermelon, ['visible=?', true], {}, {})
        expect(rule.inspect).not_to be_blank
      end
    end
  end
end
