require 'spec_helper'

describe CanCan::Concepts::LoadResource do
  let(:ability) { Ability.new(nil) }
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:controller_parent) { controller_class.new }
  let(:load_resource) { CanCan::Concepts::LoadResource.new(controller, :model) }

  describe '#load' do
    it 'loads an instance if the controller is a parent' do
      allow(controller).to receive(:params) { { controller: 'model', action: :index } }
      load_resource.options[:parent] = controller_parent
      expect(load_resource.send(:load_instance?)).to be_truthy
    end

    it 'loads an instance if the controller is a singleton' do
      load_resource.options[:singleton] = true
      allow(controller).to receive(:params) { { controller: 'model', action: :show } }
    end

    it 'loads an instance if the action is a show action' do
      allow(controller).to receive(:params) { { controller: 'model', action: :show, id: 1 } }
    end

    it 'loads an instance if the action is a member action' do
      load_resource.options[:id_param] = :id_param
      allow(controller).to receive(:params) { { controller: 'model', action: :show, id_param: 1 } }
      expect(load_resource.send(:load_instance?)).to eq true
    end

    it 'loads a collection if the action is a index action' do
      allow(controller).to receive(:params) { { controller: 'model', action: :index } }
      expect(load_resource.send(:load_instance?)).to be_falsey
    end

    it 'does not load resources the user does not have access to' do
    end

    it 'does not load any resources if the user has a block on them' do
    end
  end

  describe '#load_collection?' do
  end

end
