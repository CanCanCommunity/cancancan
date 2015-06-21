require 'spec_helper'

describe CanCan::Concepts::BuildResource do
  let(:ability) { Ability.new(nil) }
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:build_resource) { CanCan::Concepts::BuildResource.new(controller, :model) }

  before do
    class Model
      attr_accessor :name

      def initialize(attributes={})
        attributes.each do |attribute, value|
          send("#{attribute}=", value)
        end
      end
    end
  end

  describe '#can_build?' do
    it 'can build on new' do
      allow(controller).to receive(:params) { { controller: 'model', action: :new } }
      expect(build_resource.can_build?).to be true
    end

    it 'can accept a custom build action' do
      allow(controller).to receive(:params) { { controller: 'model', action: :new_action } }
      build_resource.options[:new] = :new_action
      expect(build_resource.can_build?).to be true
    end

    it 'can not build on non-build actions' do
      allow(controller).to receive(:params) { { controller: 'model', action: :show } }
      expect(build_resource.can_build?).to be false
    end

  end

  describe '#build_resource' do
    before do
      allow(controller).to receive(:current_ability) { ability }
      allow(controller).to receive(:params) { { controller: 'model', action: :create, model: { name: 'a name!'} } }
    end

    it 'builds a new resource' do
      ability.can(:create, Model, name: "a name!")
      build_resource.build_resource
      model = controller.instance_variable_get(:"@model")
      expect(model).to be_present
      expect(model.name).to eq 'a name!'
    end
  end

end