require 'cancan/version'
require 'cancan/ability'
require 'cancan/rule'
require 'cancan/controller_resource'
require 'cancan/controller_additions'
require 'cancan/model_additions'
require 'cancan/exceptions'

require 'cancan/model_adapters/abstract_adapter'
require 'cancan/model_adapters/default_adapter'

if defined? ActiveRecord
  require 'cancan/model_adapters/active_record_adapter'  
  require 'cancan/model_adapters/active_record_4_adapter'
end
