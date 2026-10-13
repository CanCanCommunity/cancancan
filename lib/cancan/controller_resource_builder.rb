# frozen_string_literal: true

module CanCan
  module ControllerResourceBuilder
    protected

    def build_resource
      resource = resource_base.new(resource_params || {})
      assign_attributes(resource)
    end

    def assign_attributes(resource)
      assign_parent(resource) if @options[:singleton] && parent_resource
      initial_attributes.each do |attr_name, value|
        resource.send("#{attr_name}=", value)
      end
      resource
    end

    # The parent is assigned through the setter named after the :through option when the resource has one,
    # otherwise through the inverse of the association on the parent.
    def assign_parent(resource)
      setter = "#{parent_name}="
      setter = "#{inverse_association_name}=" unless resource.respond_to?(setter)
      resource.send(setter, parent_resource)
    end

    def inverse_association_name
      association_name = @options[:through_association] || name
      inverse = inverse_of_association(parent_resource.class, association_name)
      return inverse if inverse

      raise Error, "Cannot assign the parent to the singleton resource: #{resource_class} has no " \
                   "#{parent_name}= method and the association #{association_name} on #{parent_resource.class} " \
                   'has no inverse. Define inverse_of on the association or use a through option named after it.'
    end

    def inverse_of_association(parent_class, association_name)
      return unless parent_class.respond_to?(:reflect_on_association)

      reflection = parent_class.reflect_on_association(association_name)
      reflection && (reflection.inverse_of&.name || reflection.options[:as])
    end

    def initial_attributes
      scoped_attributes = attributes_from_parent_scope
      current_ability.attributes_for(@params[:action].to_sym, resource_class).delete_if do |key, _value|
        scoped_attributes.include?(key.to_s) || (resource_params && resource_params.include?(key))
      end
    end

    def attributes_from_parent_scope
      return [] unless @options[:through] && resource_base.respond_to?(:scope_for_create)

      resource_base.scope_for_create.keys.map(&:to_s)
    end
  end
end
