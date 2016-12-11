require "spec_helper"

describe CanCan::ControllerAdditions do
  before(:each) do
    @controller_class = Class.new
    @controller = @controller_class.new
    allow(@controller).to receive(:params) { {} }
    allow(@controller).to receive(:current_user) { :current_user }
    expect(@controller_class).to receive(:helper_method).with(:can?, :cannot?, :current_ability)
    @controller_class.send(:include, CanCan::ControllerAdditions)
  end

  it "raises ImplementationRemoved when attempting to call 'unauthorized!' on a controller" do
    expect { @controller.unauthorized! }.to raise_error(CanCan::ImplementationRemoved)
  end

  it "authorize! assigns @_authorized instance variable and pass args to current ability" do
    allow(@controller.current_ability).to receive(:authorize!).with(:foo, :bar)
    @controller.authorize!(:foo, :bar)
    expect(@controller.instance_variable_get(:@_authorized)).to be(true)
  end

  it "has a current_ability method which generates an ability for the current user" do
    expect(@controller.current_ability).to be_kind_of(Ability)
  end

  it "provides a can? and cannot? methods which go through the current ability" do
    expect(@controller.current_ability).to be_kind_of(Ability)
    expect(@controller.can?(:foo, :bar)).to be(false)
    expect(@controller.cannot?(:foo, :bar)).to be(true)
  end

  it "load_and_authorize_resource setups a before filter which passes call to ControllerResource" do
    expect(cancan_resource_class = double).to receive(:load_and_authorize_resource)
    allow(CanCan::ControllerResource).to receive(:new).with(@controller, nil, :foo => :bar) {cancan_resource_class }
    expect(@controller_class).to receive(callback_action(:before_action)).with({}) { |options, &block| block.call(@controller) }
    @controller_class.load_and_authorize_resource :foo => :bar
  end

  it "load_and_authorize_resource properly passes first argument as the resource name" do
    expect(cancan_resource_class = double).to receive(:load_and_authorize_resource)
    allow(CanCan::ControllerResource).to receive(:new).with(@controller, :project, :foo => :bar) {cancan_resource_class}
    expect(@controller_class).to receive(callback_action(:before_action)).with({}) { |options, &block| block.call(@controller) }
    @controller_class.load_and_authorize_resource :project, :foo => :bar
  end

  it "load_and_authorize_resource with :prepend prepends the before filter" do
    expect(@controller_class).to receive(callback_action(:prepend_before_action)).with({})
    @controller_class.load_and_authorize_resource :foo => :bar, :prepend => true
  end

  it "authorize_resource setups a before filter which passes call to ControllerResource" do
    expect(cancan_resource_class = double).to receive(:authorize_resource)
    allow(CanCan::ControllerResource).to receive(:new).with(@controller, nil, :foo => :bar) {cancan_resource_class}
    expect(@controller_class).to receive(callback_action(:before_action)).with(:except => :show, :if => true) { |options, &block| block.call(@controller) }
    @controller_class.authorize_resource :foo => :bar, :except => :show, :if => true
  end

  it "load_resource setups a before filter which passes call to ControllerResource" do
    expect(cancan_resource_class = double).to receive(:load_resource)
    allow(CanCan::ControllerResource).to receive(:new).with(@controller, nil, :foo => :bar) {cancan_resource_class}
    expect(@controller_class).to receive(callback_action(:before_action)).with(:only => [:show, :index], :unless => false) { |options, &block| block.call(@controller) }
    @controller_class.load_resource :foo => :bar, :only => [:show, :index], :unless => false
  end

  it "skip_authorization_check setups a before filter which sets @_authorized to true" do
    expect(@controller_class).to receive(callback_action(:before_action)).with(:filter_options) { |options, &block| block.call(@controller) }
    @controller_class.skip_authorization_check(:filter_options)
    expect(@controller.instance_variable_get(:@_authorized)).to be(true)
  end

  it "check_authorization triggers AuthorizationNotPerformed in after filter" do
    expect(@controller_class).to receive(callback_action(:after_action)).with(:only => [:test]) { |options, &block| block.call(@controller) }
    expect {
      @controller_class.check_authorization(:only => [:test])
    }.to raise_error(CanCan::AuthorizationNotPerformed)
  end

  it "check_authorization does not trigger AuthorizationNotPerformed when :if is false" do
    allow(@controller).to receive(:check_auth?) { false }
    allow(@controller_class).to receive(callback_action(:after_action)).with({}) { |options, &block| block.call(@controller) }
    expect {
      @controller_class.check_authorization(:if => :check_auth?)
    }.not_to raise_error
  end

  it "check_authorization does not trigger AuthorizationNotPerformed when :unless is true" do
    allow(@controller).to receive(:engine_controller?) { true }
    expect(@controller_class).to receive(callback_action(:after_action)).with({}) { |options, &block| block.call(@controller) }
    expect {
      @controller_class.check_authorization(:unless => :engine_controller?)
    }.not_to raise_error
  end

  it "check_authorization does not raise error when @_authorized is set" do
    @controller.instance_variable_set(:@_authorized, true)
    expect(@controller_class).to receive(callback_action(:after_action)).with(:only => [:test]) { |options, &block| block.call(@controller) }
    expect {
      @controller_class.check_authorization(:only => [:test])
    }.not_to raise_error
  end

  it "cancan_resource_class is ControllerResource by default" do
    expect(@controller.class.cancan_resource_class).to eq(CanCan::ControllerResource)
  end

  it "cancan_resource_class is InheritedResource when class includes InheritedResources::Actions" do
    allow(@controller.class).to receive(:ancestors) { ["InheritedResources::Actions"] }
    expect(@controller.class.cancan_resource_class).to eq(CanCan::InheritedResource)
  end

  it "cancan_skipper is an empty hash with :authorize and :load options and remember changes" do
    expect(@controller_class.cancan_skipper).to eq({:authorize => {}, :load => {}})
    @controller_class.cancan_skipper[:load] = true
    expect(@controller_class.cancan_skipper[:load]).to be(true)
  end

  it "skip_authorize_resource adds itself to the cancan skipper with given model name and options" do
    @controller_class.skip_authorize_resource(:project, :only => [:index, :show])
    expect(@controller_class.cancan_skipper[:authorize][:project]).to eq({:only => [:index, :show]})
    @controller_class.skip_authorize_resource(:only => [:index, :show])
    expect(@controller_class.cancan_skipper[:authorize][nil]).to eq({:only => [:index, :show]})
    @controller_class.skip_authorize_resource(:article)
    expect(@controller_class.cancan_skipper[:authorize][:article]).to eq({})
  end

  it "skip_load_resource adds itself to the cancan skipper with given model name and options" do
    @controller_class.skip_load_resource(:project, :only => [:index, :show])
    expect(@controller_class.cancan_skipper[:load][:project]).to eq({:only => [:index, :show]})
    @controller_class.skip_load_resource(:only => [:index, :show])
    expect(@controller_class.cancan_skipper[:load][nil]).to eq({:only => [:index, :show]})
    @controller_class.skip_load_resource(:article)
    expect(@controller_class.cancan_skipper[:load][:article]).to eq({})
  end

  it "skip_load_and_authore_resource adds itself to the cancan skipper with given model name and options" do
    @controller_class.skip_load_and_authorize_resource(:project, :only => [:index, :show])
    expect(@controller_class.cancan_skipper[:load][:project]).to eq({:only => [:index, :show]})
    expect(@controller_class.cancan_skipper[:authorize][:project]).to eq({:only => [:index, :show]})
  end

  private

  def callback_action(action)
    if ActiveSupport.respond_to?(:version) && ActiveSupport.version >= Gem::Version.new("4")
      action
    else
      action.to_s.sub(/_action/, '_filter')
    end
  end
end
