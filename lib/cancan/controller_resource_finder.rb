module CanCan
  module ControllerResourceFinder
    protected

    def find_resource
      if @options[:singleton] && parent_resource.respond_to?(name)
        parent_resource.send(name)
      elsif @options[:find_by]
        find_resource_using_find_by
      else
        adapter.find(resource_base, id_param)
      end
    end

    def find_resource_using_find_by
      if resource_base.respond_to? 'find_by'
        resource_base.send('find_by', @options[:find_by].to_sym => id_param)
      else
        resource_base.send(@options[:find_by], id_param)
      end
    end

    def id_param
      @params[id_param_key].to_s if @params[id_param_key].present?
    end

    def id_param_key
      if @options[:id_param]
        @options[:id_param]
      else
        parent? ? :"#{name}_id" : :id
      end
    end
  end
end
