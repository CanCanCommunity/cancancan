require 'spec_helper'

describe CanCan::Concepts::Accessor do
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:accessor) { CanCan::Concepts::Accessor.new(controller, :model) }

  describe '#get' do
    it 'gets the controllers variables for an instance' do
      controller.instance_variable_set :"@model", "hello world!"
      expect(accessor.get(:instance)).to eq "hello world!"
    end

    it 'gets the controllers variables for a collection' do
      controller.instance_variable_set :"@models", "hello worlds!"
      expect(accessor.get(:collection)).to eq "hello worlds!"
    end
  end

  describe '#set' do
    it 'sets the controllers variables for an instance' do
      accessor.set(:instance, "hello world!")
      expect(controller.instance_variable_get(:"@model")).to eq "hello world!"
    end

    it 'sets the controllers variables for a collection' do
      accessor.set(:collection, "hello worlds!")
      expect(controller.instance_variable_get(:"@models")).to eq "hello worlds!"
    end
  end
end