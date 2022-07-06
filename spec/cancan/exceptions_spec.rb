# frozen_string_literal: true

require 'spec_helper'

describe CanCan::AccessDenied do
  describe 'with action, subject, and conditions' do
    before(:each) do
      @exception = CanCan::AccessDenied.new(nil, :some_action, :some_subject, :some_conditions)
    end

    it 'has action, subject, and conditions accessors' do
      expect(@exception.action).to eq(:some_action)
      expect(@exception.subject).to eq(:some_subject)
      expect(@exception.conditions).to eq(:some_conditions)
    end

    it 'has a changeable default message' do
      expect(@exception.message).to eq('You are not authorized to access this page.')
      @exception.default_message = 'Unauthorized!'
      expect(@exception.message).to eq('Unauthorized!')
    end

    it 'has debug information on inspect' do
      expect(@exception.inspect).to eq(
        '#<CanCan::AccessDenied action: :some_action, subject: :some_subject, conditions: :some_conditions>'
      )
    end
  end

  describe 'with only a message' do
    before(:each) do
      @exception = CanCan::AccessDenied.new('Access denied!')
    end

    it 'has nil action, subject, and conditions' do
      expect(@exception.action).to be_nil
      expect(@exception.subject).to be_nil
      expect(@exception.conditions).to be_nil
    end

    it 'has passed message' do
      expect(@exception.message).to eq('Access denied!')
    end
  end

  describe 'i18n in the default message' do
    after(:each) do
      I18n.backend = nil
    end

    it 'uses i18n for the default message' do
      I18n.backend.store_translations :en, unauthorized: { default: 'This is a different message' }
      @exception = CanCan::AccessDenied.new
      expect(@exception.message).to eq('This is a different message')
    end

    it 'defaults to a nice message' do
      @exception = CanCan::AccessDenied.new
      expect(@exception.message).to eq('You are not authorized to access this page.')
    end

    it 'does not use translation if a message is given' do
      @exception = CanCan::AccessDenied.new("Hey! You're not welcome here")
      expect(@exception.message).to eq("Hey! You're not welcome here")
      expect(@exception.message).to_not eq('You are not authorized to access this page.')
    end
  end
end
