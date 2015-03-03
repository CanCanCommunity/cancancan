module CanCan
  # Handle the load and authorization controller logic so we don't clutter up all controllers with non-interface methods.
  # This class is used internally, so you do not need to call methods directly on it.
  class ControllerResource # :nodoc:
    BEFORE_FILTER_PARAMS = [:only, :except, :if, :unless]

    attr_reader :controller

    def self.add_before_filter(controller_class, method, *args)
      options = args.extract_options!
      resource_name = args.first
      before_filter_method = options.delete(:prepend) ? :prepend_before_filter : :before_filter

      controller_class.__send__(before_filter_method, options.slice(*BEFORE_FILTER_PARAMS)) do |controller|
        resource_options = options.except(*BEFORE_FILTER_PARAMS)
        resource = controller.class.cancan_resource_class.new(controller, resource_name, resource_options)
        resource.__send__(method)
      end
    end

    def initialize(controller, *args)
      @controller = controller
      @params = controller.params
      @options = args.extract_options!
      @name = args.first

      if @options.has_key?(:nested)
        raise CanCan::ImplementationRemoved, 'The :nested option is no longer supported, instead use :through with separate load/authorize call.'
      end
      if @options.has_key?(:name)
        raise CanCan::ImplementationRemoved, 'The :name option is no longer supported, instead pass the name as the first argument.'
      end
      if @options.has_key?(:resource)
        raise CanCan::ImplementationRemoved, 'The :resource option has been renamed back to :class, use false if no class.'
      end
    end

    def load_and_authorize_resource
      load_resource
      authorize_resource
    end

    def load_resource
      return if skip?(:load)
      loader.load_resource
    end

    def authorize_resource
      return if skip?(:authorize)
      @controller.authorize!(authorization_action, authorization_resource)
    end

    def authorization_action
      parent? ? :show : controller_action
    end

    def authorization_resource
      return resource_instance if resource_instance
      return resource_class unless parent_resource
      {parent_resource => resource_class}
    end

    def parent?
      @options.fetch(:parent) { @name && @name != name_from_controller.to_sym }
    end

    def skip?(behavior)
      return false unless options = @controller.class.cancan_skipper[behavior][@name]

      options == {} ||
      options[:except] && !action_exists_in?(options[:except]) ||
      action_exists_in?(options[:only])
    end

    def resource_instance=(instance)
      @controller.instance_variable_set("@#{instance_name}", instance)
    end

    def resource_instance
      @controller.instance_variable_get("@#{instance_name}") if loader.load_instance?
    end

    def collection_instance=(collection)
      @controller.instance_variable_set("@#{collection_name}", collection)
    end

    def collection_instance
      @controller.instance_variable_get("@#{collection_name}")
    end

    # Returns the class used for this resource. This can be overriden by the :class option.
    # If +false+ is passed in it will use the resource name as a symbol in which case it should
    # only be used for authorization, not loading since there's no class to load through.
    def resource_class
      case @options[:class]
      when false  then name.to_sym
      when nil    then namespaced_name.to_s.camelize.constantize
      when String then @options[:class].constantize
      else @options[:class]
      end
    end

    # The object to load this resource through.
    def parent_resource
      parent_tuple.last
    end

    def parent_tuple
      [*@options[:through]].each do |name|
        parent = fetch_parent(name)
        return [name, parent] if parent
      end
      [nil, nil]
    end

    def fetch_parent(name)
      if @controller.instance_variable_defined? "@#{name}"
        @controller.instance_variable_get("@#{name}")
      elsif @controller.respond_to?(name, true)
        @controller.__send__(name)
      end
    end

    def namespaced_name
      controller_namespace = @params[:controller].split(/::|\//)[0..-2]
      [controller_namespace, name.camelize].flatten.map(&:camelize).join('::').singularize.constantize
    rescue NameError
      name
    end

    def controller_action
      @params[:action].to_sym
    end

    def name
      @name || name_from_controller
    end

    def name_from_controller
      @params[:controller].sub('Controller', '').underscore.split('/').last.singularize
    end

    def instance_name
      @options.fetch(:instance_name) { name }
    end

    def collection_name
      instance_name.to_s.pluralize
    end

    def action_exists_in?(options)
      Array(options).include?(@params[:action].to_sym)
    end

    def loader
      @loader ||= Loader.new(self, @params, @options)
    end
  end
end
