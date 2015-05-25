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
      @controller     = controller
      @builder        = Helpers::Builder.new(controller, args.dup)
      @loader         = Helpers::Loader.new(controller, args.dup)
      @authorizer     = Helpers::Authorizer.new(controller, args.dup)
      @resource_class = Helpers::ResourceClass.new(controller, args.dup)
      @skipper        = Helpers::Skipper.new(controller, args.dup)
      options = args.extract_options!
      raise CanCan::ImplementationRemoved, "The :nested option is no longer supported, instead use :through with separate load/authorize call." if options[:nested]
      raise CanCan::ImplementationRemoved, "The :name option is no longer supported, instead pass the name as the first argument." if options[:name]
      raise CanCan::ImplementationRemoved, "The :resource option has been renamed back to :class, use false if no class." if options[:resource]
    end

    def load_and_authorize_resource
      load_resource
      authorize_resource
    end

    def load_resource
      @loader.load unless skip? :load
    end

    def authorize_resource
      @authorizer.authorize unless skip? :authorize
    end

    def_delegator :@skipper, :skip?

    protected

    def_delegators :@builder, :build_resource, :assign_attributes, :resource_params
    def_delegators :@loader, :parent?, :instance_name, :id_param, :assign_attributes, :resource_params

    def resource_class
      @resource_class.base
    end

  end
end
