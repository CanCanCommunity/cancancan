# FriendlyId

If you are using [FriendlyId](https://github.com/norman/friendly_id) you will probably like something to make CanCanCan compatible with it.

You do not have to write `find_by :slug` or something like that, that is always error prone.

You just need to create a `config/initializers/cancancan.rb` file with:

```ruby
if defined?(CanCanCan)
  class Object
    def metaclass
      class << self; self; end
    end
  end

  module CanCan
    module ModelAdapters
      class ActiveRecordAdapter < AbstractAdapter
        @@friendly_support = {}

        def self.find(model_class, id)
          klass =
          model_class.metaclass.ancestors.include?(ActiveRecord::Associations::CollectionProxy) ?
            model_class.klass : model_class
          @@friendly_support[klass]||=klass.metaclass.ancestors.include?(FriendlyId)
          @@friendly_support[klass] == true ? model_class.friendly.find(id) : model_class.find(id)
        end
      end
    end
  end
end
```
