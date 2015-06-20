module CanCan
  class ControllerResource # :nodoc:
    extend Forwardable

    def self.add_before_filter(controller_class, method, *args)
      options = args.extract_options!
      resource_name = args.first
      before_filter_method = options.delete(:prepend) ? :prepend_before_filter : :before_filter
      controller_class.send(before_filter_method, options.slice(:only, :except, :if, :unless)) do |controller|
        controller.class.cancan_resource_class.new(controller, resource_name, options.except(:only, :except, :if, :unless)).send(method)
      end
    end

    def initialize(controller, *args)
      options = args.extract_options!
      name = args.first
      @build_resource     = Concepts::BuildResource.new(controller, name, options)
      @load_resource      = Concepts::LoadResource.new(controller, name, options)
      @authorize_resource = Concepts::AuthorizeResource.new(controller, name, options)
      @resource_class     = Concepts::ResourceClass.new(controller, name, options)
      @override_auth      = Concepts::OverrideAuthorization.new(controller, name, options)
      raise CanCan::ImplementationRemoved, "The :nested option is no longer supported, instead use :through with separate load/authorize call." if options[:nested]
      raise CanCan::ImplementationRemoved, "The :name option is no longer supported, instead pass the name as the first argument." if options[:name]
      raise CanCan::ImplementationRemoved, "The :resource option has been renamed back to :class, use false if no class." if options[:resource]
    end

    def load_and_authorize_resource
      load_resource
      authorize_resource
    end

    def load_resource
      @load_resource.load unless skip? :load
    end

    def authorize_resource
      @authorize_resource.authorize unless skip? :authorize
    end

    def_delegator :@override_auth, :skip?

    protected

    def_delegators :@build_resource, :build_resource, :assign_attributes, :resource_params
    def_delegators :@load_resource, :parent?, :instance_name, :id_param, :assign_attributes, :resource_params

    def resource_class
      @resource_class.base
    end

  end
end
