require 'spec_helper'

describe CanCan::Concepts::AuthorizeResource do
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:controller_parent) { controller_class.new }
  let(:accessor) { CanCan::Concepts::Accessor.new(controller, :model) }
  let(:model) { Model.new }
  let(:authorize_resource) { CanCan::Concepts::AuthorizeResource.new(controller, :model) }

  describe '#authorize' do

    before do
      class Model; end
      allow(controller).to receive(:params) { { controller: 'model', action: :show } }
    end

    it 'authorizes a resource' do
      expect(controller).to receive(:authorize!).with(:show, model)
      controller.instance_variable_set :"@model", model
      authorize_resource.authorize
    end

    context 'with a parent controller' do
      before do
        authorize_resource.options[:parent] = controller_parent
      end

      it 'authorizes as normal if a resource is set' do
        expect(controller).to receive(:authorize!).with(:show, model)
        controller.instance_variable_set :"@model", model
        authorize_resource.authorize
      end

      it 'authorizes a resource via the parent when it is present' do
        expect(controller).to receive(:authorize!).with(:show, Model)
        authorize_resource.authorize
      end

      it 'can accept a parent authorization action' do
        expect(controller).to receive(:authorize!).with(:parent_show, Model)
        authorize_resource.options[:parent_action] = :parent_show
        authorize_resource.authorize
      end
    end
  end

end
