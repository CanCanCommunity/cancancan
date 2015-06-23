require 'spec_helper'

describe CanCan::Concepts::FindResource do
  let(:ability) { Ability.new(nil) }
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }
  let(:controller_parent) { controller_class.new }
  let(:find_resource) { CanCan::Concepts::FindResource.new(controller, :model) }
  let(:adapter_class) { Model.new }

  before do
      class Model; end
    allow(controller).to receive(:params) { { controller: 'model', action: :show } }
  end

  describe '#can_find?' do

    it 'returns true if the singleton option is set' do
      find_resource.options[:singleton] = true
      expect(find_resource.can_find?).to be_truthy
    end

    it 'returns true if an id field is found on the controller params' do
      allow(controller).to receive(:params) { { controller: 'model', action: :show, id: 5 } }
      expect(find_resource.can_find?).to be_truthy
    end

    it 'returns false if no id is found on the controller params' do
      expect(find_resource.can_find?).to be_falsey
    end

    it 'returns true if the id_param option is found on the controller params' do
      find_resource.options[:id_param] = :id_param
      allow(controller).to receive(:params) { { controller: 'model', action: :show, id_param: 5 } }
      expect(find_resource.can_find?).to be_truthy
    end

    it 'returns false if the id_param option is not on the controller params' do
      find_resource.options[:id_param] = :id_param
      expect(find_resource.can_find?).to be_falsey
    end
  end

  describe '#find_resource' do
    it 'finds the parent resources instance if the singleton option is set' do
      allow(controller).to receive(:model_through) { controller_parent }
      allow(controller_parent).to receive(:model) { "I am a singleton model" }
      find_resource.options[:through] = :model_through
      find_resource.options[:singleton] = true
      expect(find_resource.find_resource).to eq "I am a singleton model"
    end

    it 'finds with a find_by_field! method if it exists' do
      allow(Model).to receive(:find_by_field!) { "I am found" }
      find_resource.options[:find_by] = :field
      expect(find_resource.find_resource).to eq "I am found"
    end

    it 'finds with the find_by option method' do
      allow(Model).to receive(:find_by_field) { "I am found" }
      find_resource.options[:find_by] = :find_by_field
      expect(find_resource.find_resource).to eq "I am found"
    end

    it 'finds with a find_by method if it exists' do
      allow(Model).to receive(:find_by) { "I am found" }
      find_resource.options[:find_by] = :field
      expect(find_resource.find_resource).to eq "I am found"
    end

    it 'returns Adapter.find if no find by option is set' do
      allow(find_resource).to receive(:adapter) { adapter_class }
      allow(adapter_class).to receive(:find) { "I am a model" }
      expect(find_resource.find_resource).to eq "I am a model"
    end
  end

end