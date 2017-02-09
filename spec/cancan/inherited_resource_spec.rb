require 'spec_helper'

describe CanCan::InheritedResource do
  let(:ability) { Ability.new(nil) }
  let(:params) { HashWithIndifferentAccess.new(controller: 'models') }
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }

  before(:each) do
    class Model
      attr_accessor :name

      def initialize(attributes = {})
        attributes.each do |attribute, value|
          send("#{attribute}=", value)
        end
      end
    end

    allow(controller).to receive(:params) { params }
    allow(controller).to receive(:current_ability) { ability }
    allow(controller_class).to receive(:cancan_skipper) { { authorize: {}, load: {} } }
  end

  it 'show loads resource through controller.resource' do
    params.merge!(action: 'show', id: 123)
    allow(controller).to receive(:resource) { :model_resource }
    CanCan::InheritedResource.new(controller).load_resource
    expect(controller.instance_variable_get(:@model)).to eq(:model_resource)
  end

  it 'new loads through controller.build_resource' do
    params[:action] = 'new'
    allow(controller).to receive(:build_resource) { :model_resource }
    CanCan::InheritedResource.new(controller).load_resource
    expect(controller.instance_variable_get(:@model)).to eq(:model_resource)
  end

  it 'index loads through controller.association_chain when parent' do
    params[:action] = 'index'
    allow(controller).to receive(:association_chain) { controller.instance_variable_set(:@model, :model_resource) }
    CanCan::InheritedResource.new(controller, parent: true).load_resource
    expect(controller.instance_variable_get(:@model)).to eq(:model_resource)
  end

  it 'index loads through controller.end_of_association_chain' do
    params[:action] = 'index'
    allow(Model).to receive(:accessible_by).with(ability, :index) { :projects }
    allow(controller).to receive(:end_of_association_chain) { Model }
    CanCan::InheritedResource.new(controller).load_resource
    expect(controller.instance_variable_get(:@models)).to eq(:projects)
  end

  it 'builds a new resource with attributes from current ability' do
    params[:action] = 'new'
    ability.can(:create, Model, name: 'from conditions')
    allow(controller).to receive(:build_resource) { Struct.new(:name).new }
    resource = CanCan::InheritedResource.new(controller)
    resource.load_resource
    expect(controller.instance_variable_get(:@model).name).to eq('from conditions')
  end

  it 'overrides initial attributes with params' do
    params.merge!(action: 'new', model: { name: 'from params' })
    ability.can(:create, Model, name: 'from conditions')
    allow(controller).to receive(:build_resource) { Struct.new(:name).new }
    resource = CanCan::ControllerResource.new(controller)
    resource.load_resource
    expect(controller.instance_variable_get(:@model).name).to eq('from params')
  end
end
