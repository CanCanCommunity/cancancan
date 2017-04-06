module Cancan
  module Generators
    class AbilityGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_ability
        copy_file 'ability.rb', 'app/models/ability.rb'
      end
    end
  end
end
