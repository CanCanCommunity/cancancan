require 'spec_helper'

describe CanCan::Concepts::Base do
  let(:controller_class) { Class.new }
  let(:params) { HashWithIndifferentAccess.new(:controller => "models") }
  let(:controller) { controller_class.new }
  let(:base_class) { CanCan::Concepts::Base }

  before do
    allow(controller).to receive(:params) { params }
  end

  describe '#options' do
    it 'has a getter fo the passed options' do
      base = base_class.new(controller, :model, {option: 'value'})
      expect(base.options[:option]).to eq 'value'
    end
  end

  describe '#resource_name' do
    it 'returns the passed name if it exists' do
      base = base_class.new(controller, 'widget')
      expect(base.resource_name).to eq 'widget'
    end

    it 'returns the name of the controller if no name is passed' do
      base = base_class.new(controller, nil)
      expect(base.resource_name).to eq 'model'
    end

    it 'can handle nested controller names' do
      base = base_class.new(controller, nil)
      params[:controller] = 'parents/models'
      expect(base.resource_name).to eq 'model'
    end
  end

  describe '#instance_name' do
    it 'returns the resource_name if no instance_name option is passed' do
      base = base_class.new(controller, :model)
      expect(base.instance_name).to eq :model
    end

    it 'returns the instance_name option if it is passed' do
      base = base_class.new(controller, :model, instance_name: :something_else)
      expect(base.instance_name).to eq :something_else
    end
  end
end