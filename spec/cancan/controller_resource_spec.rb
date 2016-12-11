require "spec_helper"

describe CanCan::ControllerResource do
  let(:ability) { Ability.new(nil) }
  let(:params) { HashWithIndifferentAccess.new(:controller => "models") }
  let(:controller_class) { Class.new }
  let(:controller) { controller_class.new }

  before(:each) do
    class Model
      attr_accessor :name

      def initialize(attributes={})
        attributes.each do |attribute, value|
          send("#{attribute}=", value)
        end
      end
    end

    allow(controller).to receive(:params) { params }
    allow(controller).to receive(:current_ability) { ability }
    allow(controller_class).to receive(:cancan_skipper) { {:authorize => {}, :load => {}} }
  end

  context "on build actions" do
    before :each do
      params.merge!(:action => "new")
    end

    it "builds a new resource with attributes from current ability" do
      ability.can(:create, Model, :name => "from conditions")
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("from conditions")
    end

    it "overrides initial attributes with params" do
      params.merge!(:model => {:name => "from params"})
      ability.can(:create, Model, :name => "from conditions")
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("from params")
    end

    it "builds a resource when on custom new action even when params[:id] exists" do
      params.merge!(:action => "build", :id => "123")
      allow(Model).to receive(:new) { :some_model }
      resource = CanCan::ControllerResource.new(controller, :new => :build)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "only authorizes :show action on parent resource" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      params.merge!(:model_id => 123)
      allow(controller).to receive(:authorize!).with(:show, model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller, :model, :parent => true)
      expect { resource.load_and_authorize_resource }.to raise_error(CanCan::AccessDenied)
    end
  end

  context "on create actions" do
    before :each do
      params.merge!(:action => 'create')
    end

    # Rails includes namespace in params, see issue #349
    it "creates through the namespaced params" do
      module MyEngine
        class Model < ::Model; end
      end

      params.merge!(:controller => "my_engine/models", :my_engine_model => {:name => "foobar"})
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("foobar")
    end

    it "builds a new resource with hash if params[:id] is not specified" do
      params.merge!(:model => {:name => "foobar"})
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("foobar")
    end

    it "builds a new resource for namespaced model with hash if params[:id] is not specified" do
      module Sub
        class Model < ::Model; end
      end

      params.merge!('sub_model' => {:name => "foobar"})
      resource = CanCan::ControllerResource.new(controller, :class => ::Sub::Model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("foobar")
    end

    it "builds a new resource for namespaced controller and namespaced model with hash if params[:id] is not specified" do
      params.merge!(:controller => "admin/sub_models", 'sub_model' => {:name => "foobar"})
      resource = CanCan::ControllerResource.new(controller, :class => Model)
      resource.load_resource
      expect(controller.instance_variable_get(:@sub_model).name).to eq("foobar")
    end

    it "builds a new resource for namespaced controller given through folder format" do
      module Admin
        module SubModule
          class HiddenModel < ::Model; end
        end
      end
      params.merge!(:controller => "admin/sub_module/hidden_models")
      resource = CanCan::ControllerResource.new(controller)
      expect { resource.load_resource }.not_to raise_error
    end

    it "does not build record through has_one association with :singleton option because it can cause it to delete it in the database" do
      category = Class.new
      allow_any_instance_of(Model).to receive('category=').with(category)
      allow_any_instance_of(Model).to receive('category') { category }

      params.merge!(:model => {:name => "foobar"})

      controller.instance_variable_set(:@category, category)
      resource = CanCan::ControllerResource.new(controller, :through => :category, :singleton => true)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("foobar")
      expect(controller.instance_variable_get(:@model).category).to eq(category)
    end

    it "builds record through has_one association with :singleton and :shallow options" do
      params.merge!(:model => {:name => "foobar"})
      resource = CanCan::ControllerResource.new(controller, :through => :category, :singleton => true, :shallow => true)
      resource.load_resource
      expect(controller.instance_variable_get(:@model).name).to eq("foobar")
    end

    context "with a strong parameters method" do
      before :each do
        params.merge!(:controller => "model", :model => { :name => 'test'})
      end

      it "accepts and uses the specified symbol for santitizing input" do
        allow(controller).to receive(:resource_params).and_return(:resource => 'params')
        allow(controller).to receive(:model_params).and_return(:model => 'params')
        allow(controller).to receive(:create_params).and_return(:create => 'params')
        allow(controller).to receive(:custom_params).and_return(:custom => 'params')
        resource = CanCan::ControllerResource.new(controller, {:param_method => :custom_params})
        expect(resource.send("resource_params")).to eq(:custom => 'params')
      end

      it "accepts the specified string for sanitizing input" do
        resource = CanCan::ControllerResource.new(controller, {:param_method => "{:custom => 'params'}"})
        expect(resource.send("resource_params")).to eq(:custom => 'params')
      end

      it "accepts the specified proc for sanitizing input" do
        resource = CanCan::ControllerResource.new(controller, {:param_method => Proc.new { |c| {:custom => 'params'}}})
        expect(resource.send("resource_params")).to eq(:custom => 'params')
      end

      it "prefers to use the create_params method for santitizing input" do
        allow(controller).to receive(:resource_params).and_return(:resource => 'params')
        allow(controller).to receive(:model_params).and_return(:model => 'params')
        allow(controller).to receive(:create_params).and_return(:create => 'params')
        allow(controller).to receive(:custom_params).and_return(:custom => 'params')
        resource = CanCan::ControllerResource.new(controller)
        expect(resource.send("resource_params")).to eq(:create => 'params')
      end

      it "prefers to use the <model_name>_params method for santitizing input if create is not found" do
        allow(controller).to receive(:resource_params).and_return(:resource => 'params')
        allow(controller).to receive(:model_params).and_return(:model => 'params')
        allow(controller).to receive(:custom_params).and_return(:custom => 'params')
        resource = CanCan::ControllerResource.new(controller)
        expect(resource.send("resource_params")).to eq(:model => 'params')
      end

      it "prefers to use the resource_params method for santitizing input if create or model is not found" do
        allow(controller).to receive(:resource_params).and_return(:resource => 'params')
        allow(controller).to receive(:custom_params).and_return(:custom => 'params')
        resource = CanCan::ControllerResource.new(controller)
        expect(resource.send("resource_params")).to eq(:resource => 'params')
      end
    end
  end

  context "on collection actions" do
    before :each do
      params[:action] = 'index'
    end

    it "builds a collection when on index action when class responds to accessible_by" do
      allow(Model).to receive(:accessible_by).with(ability, :index) { :found_models }

      resource = CanCan::ControllerResource.new(controller, :model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
      expect(controller.instance_variable_get(:@models)).to eq(:found_models)
    end

    it "does not build a collection when on index action when class does not respond to accessible_by" do
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
      expect(controller.instance_variable_defined?(:@models)).to be(false)
    end

    it "does not use accessible_by when defining abilities through a block" do
      allow(Model).to receive(:accessible_by).with(ability) { :found_models }

      ability.can(:read, Model) { |p| false }
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
      expect(controller.instance_variable_defined?(:@models)).to be(false)
    end

    it "does not authorize single resource in collection action" do
      allow(controller).to receive(:authorize!).with(:index, Model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller)

      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "authorizes parent resource in collection action" do
      controller.instance_variable_set(:@category, :some_category)
      allow(controller).to receive(:authorize!).with(:show, :some_category) { raise CanCan::AccessDenied }

      resource = CanCan::ControllerResource.new(controller, :category, :parent => true)
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "authorizes with :custom_action for parent collection action" do
      controller.instance_variable_set(:@category, :some_category)
      allow(controller).to receive(:authorize!).with(:custom_action, :some_category) { raise CanCan::AccessDenied }

      resource = CanCan::ControllerResource.new(controller, :category, :parent => true, :parent_action => :custom_action )
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "has the specified nested resource_class when using / for namespace" do
      module Admin
        class Dashboard; end
      end
      ability.can(:index, "admin/dashboard")
      params.merge!(:controller => "admin/dashboard")
      resource = CanCan::ControllerResource.new(controller, :authorize => true)
      expect(resource.send(:resource_class)).to eq(Admin::Dashboard)
    end

    it "does not build a single resource when on custom collection action even with id" do
      params.merge!(:action => "sort", :id => "123")

      resource = CanCan::ControllerResource.new(controller, :collection => [:sort, :list])
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
    end

    it "loads a collection resource when on custom action with no id param" do
      allow(Model).to receive(:accessible_by).with(ability, :sort) { :found_models }
      params[:action] = "sort"
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
      expect(controller.instance_variable_get(:@models)).to eq(:found_models)
    end

    it "loads parent resource through proper id parameter" do
      model = Model.new
      allow(Model).to receive(:find).with("1") { model }

      params.merge!(:controller => "categories", :model_id => 1)
      resource = CanCan::ControllerResource.new(controller, :model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "authorizes nested resource through parent association on index action" do
      controller.instance_variable_set(:@category, category = double)
      allow(controller).to receive(:authorize!).with(:index, category => Model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller, :through => :category)
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end
  end

  context "on instance read actions" do
    before :each do
      params.merge!(:action => "show", :id => "123")
    end

    it "loads the resource into an instance variable if params[:id] is specified" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "does not load resource into an instance variable if already set" do
      controller.instance_variable_set(:@model, :some_model)
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "loads resource for namespaced controller" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }
      params.merge!(:controller => "admin/models")

      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "performs authorization using controller action and loaded model" do
      controller.instance_variable_set(:@model, :some_model)
      allow(controller).to receive(:authorize!).with(:show, :some_model) { raise CanCan::AccessDenied }

      resource = CanCan::ControllerResource.new(controller)
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "performs authorization using controller action and non loaded model" do
      allow(controller).to receive(:authorize!).with(:show, Model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller)
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "calls load_resource and authorize_resource for load_and_authorize_resource" do
      resource = CanCan::ControllerResource.new(controller)
      expect(resource).to receive(:load_resource)
      expect(resource).to receive(:authorize_resource)
      resource.load_and_authorize_resource
    end

    it "loads resource through the association of another parent resource using instance variable" do
      category = double(:models => {})
      controller.instance_variable_set(:@category, category)
      allow(category.models).to receive(:find).with("123") { :some_model }
      resource = CanCan::ControllerResource.new(controller, :through => :category)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "loads resource through the custom association name" do
      category = double(:custom_models => {})
      controller.instance_variable_set(:@category, category)
      allow(category.custom_models).to receive(:find).with("123") { :some_model }
      resource = CanCan::ControllerResource.new(controller, :through => :category, :through_association => :custom_models)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "loads resource through the association of another parent resource using method" do
      category = double(:models => {})
      allow(controller).to receive(:category) { category }
      allow(category.models).to receive(:find).with("123") { :some_model }
      resource = CanCan::ControllerResource.new(controller, :through => :category)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "does not load through parent resource if instance isn't loaded when shallow" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      resource = CanCan::ControllerResource.new(controller, :through => :category, :shallow => true)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "raises AccessDenied when attempting to load resource through nil" do
      resource = CanCan::ControllerResource.new(controller, :through => :category)
      expect {
        resource.load_resource
      }.to raise_error(CanCan::AccessDenied) { |exception|
        expect(exception.action).to eq(:show)
        expect(exception.subject).to eq(Model)
      }
      expect(controller.instance_variable_get(:@model)).to be_nil
    end

    it "loads through first matching if multiple are given" do
      category = double(:models => {})
      controller.instance_variable_set(:@category, category)
      allow(category.models).to receive(:find).with("123") { :some_model }

      resource = CanCan::ControllerResource.new(controller, :through => [:category, :user])
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "finds record through has_one association with :singleton option without id param" do
      params.merge!(:id => nil)

      category = double(:model => :some_model)
      controller.instance_variable_set(:@category, category)
      resource = CanCan::ControllerResource.new(controller, :through => :category, :singleton => true)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(:some_model)
    end

    it "does not try to load resource for other action if params[:id] is undefined" do
      params.merge!(:action => 'list', :id => nil)
      resource = CanCan::ControllerResource.new(controller)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to be_nil
    end

    it "finds record through has_one association with :singleton and :shallow options" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      resource = CanCan::ControllerResource.new(controller, :through => :category, :singleton => true, :shallow => true)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "loads the model using a custom class" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      resource = CanCan::ControllerResource.new(controller, :class => Model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "loads the model using a custom namespaced class" do
      module Sub
        class Model < ::Model; end
      end

      model = Sub::Model.new
      allow(Sub::Model).to receive(:find).with("123") { model }

      resource = CanCan::ControllerResource.new(controller, :class => ::Sub::Model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "authorizes based on resource name if class is false" do
      allow(controller).to receive(:authorize!).with(:show, :model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller, :class => false)
      expect { resource.authorize_resource }.to raise_error(CanCan::AccessDenied)
    end

    it "loads and authorize using custom instance name" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      allow(controller).to receive(:authorize!).with(:show, model) { raise CanCan::AccessDenied }
      resource = CanCan::ControllerResource.new(controller, :instance_name => :custom_model)
      expect { resource.load_and_authorize_resource }.to raise_error(CanCan::AccessDenied)
      expect(controller.instance_variable_get(:@custom_model)).to eq(model)
    end

    it "loads resource using custom ID param" do
      model = Model.new
      allow(Model).to receive(:find).with("123") { model }

      params.merge!(:the_model => 123)
      resource = CanCan::ControllerResource.new(controller, :id_param => :the_model)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    # CVE-2012-5664
    it "always converts id param to string" do
      params.merge!(:the_model => { :malicious => "I am" })
      resource = CanCan::ControllerResource.new(controller, :id_param => :the_model)
      expect(resource.send(:id_param).class).to eq(String)
    end

    it "should id param return nil if param is nil" do
      params.merge!(:the_model => nil)
      resource = CanCan::ControllerResource.new(controller, :id_param => :the_model)
      expect(resource.send(:id_param)).to be_nil
    end

    it "loads resource using custom find_by attribute" do
      model = Model.new
      allow(Model).to receive(:name).with('foo') { model }

      params.merge!(:action => "show", :id => "foo")
      resource = CanCan::ControllerResource.new(controller, :find_by => :name)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end

    it "allows full find method to be passed into find_by option" do
      model = Model.new
      allow(Model).to receive(:find_by_name).with('foo') { model }

      params.merge!(:action => "show", :id => "foo")
      resource = CanCan::ControllerResource.new(controller, :find_by => :find_by_name)
      resource.load_resource
      expect(controller.instance_variable_get(:@model)).to eq(model)
    end
  end

  context 'when @name passed as symbol' do
    it 'returns namespaced #resource_class' do
      module Admin; end
      class Admin::Dashboard; end;
      params.merge!(:controller => "admin/dashboard")
      resource = CanCan::ControllerResource.new(controller, :dashboard)

      expect(resource.send(:resource_class)).to eq Admin::Dashboard
    end
  end

  it "calls the santitizer when the parameter hash matches our object" do
    params.merge!(:action => 'create', :model => { :name => 'test' })
    allow(controller).to receive(:create_params).and_return({})

    resource = CanCan::ControllerResource.new(controller)
    resource.load_resource
    expect(controller.instance_variable_get(:@model).name).to eq nil
  end

  it "santitizes correctly when the instance name is overriden" do
    params.merge!(:action => 'create', :custom_name => {:name => "foobar"})
    allow(controller).to receive(:create_params).and_return({})

    resource = CanCan::ControllerResource.new(controller, :instance_name => :custom_name)
    resource.load_resource
    expect(controller.instance_variable_get(:@custom_name).name).to eq nil
  end

  it "calls the santitize method on non-save actions when required" do
    params.merge!(:action => 'new', :model => { :name => 'test' })

    allow(controller).to receive(:resource_params).and_return({})
    resource = CanCan::ControllerResource.new(controller)
    resource.load_resource
    expect(controller.instance_variable_get(:@model).name).to eq nil
  end

  it "doesn't sanitize parameters on non-save actions when not required" do
    params.merge!(:action => 'new', :not_our_model => { :name => 'test' })
    allow(controller).to receive(:resource_params).and_raise

    resource = CanCan::ControllerResource.new(controller)
    expect {
      resource.load_resource
    }.to_not raise_error
  end

  it "is a parent resource when name is provided which doesn't match controller" do
    resource = CanCan::ControllerResource.new(controller, :category)
    expect(resource).to be_parent
  end

  it "does not be a parent resource when name is provided which matches controller" do
    resource = CanCan::ControllerResource.new(controller, :model)
    expect(resource).to_not be_parent
  end

  it "is parent if specified in options" do
    resource = CanCan::ControllerResource.new(controller, :model, {:parent => true})
    expect(resource).to be_parent
  end

  it "does not be parent if specified in options" do
    resource = CanCan::ControllerResource.new(controller, :category, {:parent => false})
    expect(resource).to_not be_parent
  end

  it "has the specified resource_class if 'name' is passed to load_resource" do
    class Section; end
    resource = CanCan::ControllerResource.new(controller, :section)
    expect(resource.send(:resource_class)).to eq(Section)
  end

  it "raises ImplementationRemoved when adding :name option" do
    expect {
      CanCan::ControllerResource.new(controller, :name => :foo)
    }.to raise_error(CanCan::ImplementationRemoved)
  end

  it "raises ImplementationRemoved exception when specifying :resource option since it is no longer used" do
    expect {
      CanCan::ControllerResource.new(controller, :resource => Model)
    }.to raise_error(CanCan::ImplementationRemoved)
  end

  it "raises ImplementationRemoved exception when passing :nested option" do
    expect {
      CanCan::ControllerResource.new(controller, :nested => :model)
    }.to raise_error(CanCan::ImplementationRemoved)
  end

  it "skips resource behavior for :only actions in array" do
    allow(controller_class).to receive(:cancan_skipper) { {:load => {nil => {:only => [:index, :show]}}} }
    params.merge!(:action => "index")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be(true)
    expect(CanCan::ControllerResource.new(controller, :some_resource).skip?(:load)).to be(false)
    params.merge!(:action => "show")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be(true)
    params.merge!(:action => "other_action")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be_falsey
  end

  it "skips resource behavior for :only one action on resource" do
    allow(controller_class).to receive(:cancan_skipper) { {:authorize => {:model => {:only => :index}}} }
    params.merge!(:action => "index")
    expect(CanCan::ControllerResource.new(controller).skip?(:authorize)).to be(false)
    expect(CanCan::ControllerResource.new(controller, :model).skip?(:authorize)).to be(true)
    params.merge!(:action => "other_action")
    expect(CanCan::ControllerResource.new(controller, :model).skip?(:authorize)).to be_falsey
  end

  it "skips resource behavior :except actions in array" do
    allow(controller_class).to receive(:cancan_skipper) { {:load => {nil => {:except => [:index, :show]}}} }
    params.merge!(:action => "index")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be_falsey
    params.merge!(:action => "show")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be_falsey
    params.merge!(:action => "other_action")
    expect(CanCan::ControllerResource.new(controller).skip?(:load)).to be(true)
    expect(CanCan::ControllerResource.new(controller, :some_resource).skip?(:load)).to be(false)
  end

  it "skips resource behavior :except one action on resource" do
    allow(controller_class).to receive(:cancan_skipper) { {:authorize => {:model => {:except => :index}}} }
    params.merge!(:action => "index")
    expect(CanCan::ControllerResource.new(controller, :model).skip?(:authorize)).to be_falsey
    params.merge!(:action => "other_action")
    expect(CanCan::ControllerResource.new(controller).skip?(:authorize)).to be(false)
    expect(CanCan::ControllerResource.new(controller, :model).skip?(:authorize)).to be(true)
  end

  it "skips loading and authorization" do
    allow(controller_class).to receive(:cancan_skipper) { {:authorize => {nil => {}}, :load => {nil => {}}} }
    params.merge!(:action => "new")
    resource = CanCan::ControllerResource.new(controller)
    expect { resource.load_and_authorize_resource }.not_to raise_error
    expect(controller.instance_variable_get(:@model)).to be_nil
  end
end
