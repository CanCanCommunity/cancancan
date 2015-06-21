require 'spec_helper'

describe CanCan::Concepts::ResourceClass do
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:controller_parent) { controller_class.new }
  let(:controller_parent_models) { [Model.new, Model.new, Model.new] }
  let(:controller_parent_models_scoped) { [Model.new, Model.new] }

  before do
    class Model; end
  end

  describe '#base' do
    context 'through option is specified' do
      before do
        allow(controller).to receive(:model_through) { controller_parent }
        allow(controller_parent).to receive(:models) { controller_parent_models }
        @resource_class = CanCan::Concepts::ResourceClass.new(controller, 'model', { through: :model_through })
      end

      context 'Active Record 3 scoping' do
        before do
          allow(controller_parent_models).to receive(:scoped) { controller_parent_models_scoped }
        end

        it 'does not scope outside of ActiveRecord 3' do
          return unless defined? ActiveRecord
          expect(@resource_class.base).to eq controller_parent_models unless ActiveRecord::VERSION::MAJOR == 3
        end

        it 'can handle ActiveRecord 3 scoped' do
          return unless defined? ActiveRecord
          expect(@resource_class.base).to eq controller_parent_models_scoped if ActiveRecord::VERSION::MAJOR == 3
        end
      end

      context 'parent association exists' do
        it 'returns the parents association when it exists' do
          expect(@resource_class.base).to eq controller_parent_models
        end

        it 'returns the current class if it is a singleton' do
          @resource_class.options[:singleton] = true
          expect(@resource_class.base).to eq Model
        end

        it 'can accept a through_association option' do
          allow(controller_parent).to receive(:custom_association) { controller_parent_models_scoped }
          @resource_class.options[:through_association] = :custom_association
          expect(@resource_class.base).to eq controller_parent_models_scoped
        end
      end

      context 'parent association cannot be found exist' do
        before do
          @resource_class.options[:through] = :not_a_thing
          allow(controller).to receive(:params) { { controller: 'not_a_controller' } }
        end

        it 'raises a record not found error if parent resource is not found' do
          expect { @resource_class.base }.to raise_error CanCan::AccessDenied
        end

        it 'returns the normal resource class when the shallow option is specified and no parent class exists' do
          @resource_class.options[:shallow] = true
          expect(@resource_class.base).to eq Model
        end
      end
    end

    context 'through option is not specified' do
      before do
        @resource_class = CanCan::Concepts::ResourceClass.new(controller, 'model')
        class Custom; end
        module Deep; module Nested; class Model; end; end; end
      end

      it 'returns the namespaced constant when no class option is specified' do
        expect(@resource_class.resource_class).to eq Model
      end

      it 'can handle a nested controller' do
        allow(controller).to receive(:params) { HashWithIndifferentAccess.new(controller: 'deep/nested/model') }
        @resource_class.options[:class] = nil
        expect(@resource_class.resource_class).to eq Deep::Nested::Model
      end

      it 'returns the class option when specified' do
        @resource_class.options[:class] = Custom
        expect(@resource_class.resource_class).to eq Custom
      end

      it 'returns a class when the class option is a string' do
        @resource_class.options[:class] = 'Custom'
        expect(@resource_class.resource_class).to eq Custom
      end

      it 'returns the resource name when the class option is false' do
        @resource_class.options[:class] = false
        expect(@resource_class.resource_class).to eq :model
      end
    end
  end

end
