require 'spec_helper'
require 'ostruct' # for OpenStruct below

# Most of Rule functionality is tested in Ability specs
describe CanCan::Rule do
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
end
