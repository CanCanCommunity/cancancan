require "cancan/version"
require 'cancan/ability'
require 'cancan/rule'
require 'cancan/helpers/utils/actions'
require 'cancan/helpers/utils/authorization'
require 'cancan/helpers/utils/id_param'
require 'cancan/helpers/utils/name_methods'
require 'cancan/helpers/utils/options'
require 'cancan/helpers/utils/parent'
require 'cancan/helpers/utils/resource_class'
require 'cancan/helpers/utils/resource_class_parent'
require 'cancan/helpers/base'
require 'cancan/helpers/accessor'
require 'cancan/helpers/authorizer'
require 'cancan/helpers/builder'
require 'cancan/helpers/finder'
require 'cancan/helpers/loader'
require 'cancan/helpers/inherited_resources_loader'
require 'cancan/helpers/resource_class'
require 'cancan/helpers/skipper'
require 'cancan/controller_resource'
require 'cancan/controller_additions'
require 'cancan/model_additions'
require 'cancan/exceptions'
require 'cancan/inherited_resource'

require 'cancan/model_adapters/abstract_adapter'
require 'cancan/model_adapters/default_adapter'

if defined? ActiveRecord
  require 'cancan/model_adapters/active_record_adapter'
  if ActiveRecord.respond_to?(:version) &&
      ActiveRecord.version >= Gem::Version.new("4")
    require 'cancan/model_adapters/active_record_4_adapter'
  else
    require 'cancan/model_adapters/active_record_3_adapter'
  end
end

require 'cancan/model_adapters/data_mapper_adapter' if defined? DataMapper
require 'cancan/model_adapters/mongoid_adapter' if defined?(Mongoid) && defined?(Mongoid::Document)
require 'cancan/model_adapters/sequel_adapter' if defined? Sequel
