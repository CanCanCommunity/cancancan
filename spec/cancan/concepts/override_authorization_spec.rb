require 'spec_helper'

describe CanCan::Concepts::OverrideAuthorization do
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:override_auth) { CanCan::Concepts::OverrideAuthorization.new(controller, :model) }
  let(:default_skipper) { { :authorize => { :model => {} } } }

  before(:each) do
    allow(controller).to receive(:params) { HashWithIndifferentAccess.new(:action => :show) }
    allow(controller_class).to receive(:cancan_skipper) { default_skipper }
  end

  describe '#skip?' do
    it 'returns false if skip options are null' do
      default_skipper[:authorize][:model] = nil
      expect(override_auth.skip?(:authorize)).to eq false
    end

    it 'returns true if skip options are empty' do
      default_skipper[:authorize][:model] = {}
      expect(override_auth.skip?(:authorize)).to eq true
    end

    it 'returns false if action is present in except block' do
      default_skipper[:authorize][:model][:except] = [:show]
      expect(override_auth.skip?(:authorize)).to eq false
    end

    it 'returns true if action is absent from except block' do
      default_skipper[:authorize][:model][:except] = [:index]
      expect(override_auth.skip?(:authorize)).to eq true
    end

    it 'returns false if action is present in only block' do
      default_skipper[:authorize][:model][:only] = [:show]
      expect(override_auth.skip?(:authorize)).to eq true
    end

    it 'returns true if action is absent from only block' do
      default_skipper[:authorize][:model][:only] = [:index]
      expect(override_auth.skip?(:authorize)).to eq false
    end
  end
end
