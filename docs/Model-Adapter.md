CanCan includes a model adapter layer which allows it to change behavior depending on the model used. The current adapters are.

* ActiveRecord
* [[Mongoid]]

See [[spec/README|https://github.com/CanCanCommunity/cancancan/blob/master/spec/README.rdoc]] for how to run specs for a given adapter.

## Creating a Model Adapter

It is easy to make your own adapter if one is not provided. Here I'll walk you through the steps to recreate the Mongoid adapter.

### The Specs

First, fork the CanCan GitHub project and clone that repo. Next, add the necessary gems to the Gemfile for working with the adapter in the specs.

```ruby
case ENV["MODEL_ADAPTER"]
# ...
when "mongoid"
  gem "bson_ext", "~> 1.1"
  gem "mongoid", "~> 2.0.0.beta.20"
# ...
end
```

Next create a spec for the adapter which tests basic behavior. For example, here's a simple Mongoid spec that would go under `spec/cancan/model_adapters/mongoid_adapter_spec.rb`

```ruby
if ENV["MODEL_ADAPTER"] == "mongoid"
  require "spec_helper"

  class MongoidProject
    include Mongoid::Document
  end

  Mongoid.configure do |config|
    config.master = Mongo::Connection.new('127.0.0.1', 27017).db("cancan_mongoid_spec")
  end

  describe CanCan::ModelAdapters::MongoidAdapter do
    context "Mongoid defined" do
      before(:each) do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
      end

      it "should return the correct records based on the defined ability" do
        @ability.can :read, MongoidProject, :title => "Sir"
        sir   = MongoidProject.create(:title => 'Sir')
        lord  = MongoidProject.create(:title => 'Lord')
        MongoidProject.accessible_by(@ability, :read).entries.should == [sir]
      end
    end
  end
end
```

You will need many more specs for full coverage but add them one at a time. To run the specs execute the following commands.

```bash
MODEL_ADAPTER=mongoid bundle
MODEL_ADAPTER=mongoid rake
```

That will fail since we have not added the implementation.

### The Implementation

First add a line to `lib/cancan.rb` for including the adapter only when Mongoid is present.

```ruby
require 'cancan/model_adapters/mongoid_adapter' if defined? Mongoid
```

Next create that adapter under `lib/cancan/model_adapters/mongoid_adapter.rb`.

```ruby
module CanCan
  module ModelAdapters
    class MongoidAdapter < AbstractAdapter
      def self.for_class?(model_class)
        model_class <= Mongoid::Document
      end

      def database_records
        if @rules.size == 0  
          @model_class.where(:_id => {'$exists' => false, '$type' => 7}) # return no records in Mongoid
        else
          @rules.inject(@model_class.all) do |records, rule|
            if rule.base_behavior
              records.or(rule.conditions)
            else
              records.excludes(rule.conditions)
            end
          end
        end
      end
    end
  end
end

module Mongoid::Document::ClassMethods
  include CanCan::ModelAdditions::ClassMethods
end
```

The class method called `for_class?` is used to determine if this adapter should be used for a given class. Here we just see if that model is a Mongoid document.

The `database_records` method is used in the `accessible_by` call. Here we fetch records from `@model_class` which match the `@rules`. If there are no rules then we return a query which fetches no records.

Otherwise we start with all the records and apply each of the rule conditions to them. The `rule.base_behavior` defines whether this rule should be additive or subtractive. It is `true` for a `can` call and `false` for a `cannot` call.

The last three lines add the `accessible_by` method to all Mongoid classes. I expect this to not be necessary in CanCan 2.0 (see [[issue #235|https://github.com/ryanb/cancan/issues#issue/235]]).

Some models add additional features to the conditions hash. With Mongoid you can do something like `:age.gt => 13`. To get this working a couple more methods need to be added to the adapter to override how conditions are checked.

```ruby
# in MongoidAdapter
def self.override_conditions_hash_matching?(subject, conditions)
  conditions.any? { |k,v| !k.kind_of?(Symbol) }
end

def self.matches_conditions_hash?(subject, conditions)
  subject.matches? subject.class.where(conditions).selector
end
```

The first one returns `true` when there's a conditions option which is not a Symbol (such as `:age.gt`). The second method will be called by CanCan when the first one returns true to check if the given subject matches the hash of conditions.

See the actual [[mongoid_adapter_spec.rb|https://github.com/ryanb/cancan/blob/master/spec/cancan/model_adapters/mongoid_adapter_spec.rb]] and [[mongoid_adapter.rb|https://github.com/ryanb/cancan/blob/master/lib/cancan/model_adapters/mongoid_adapter.rb]] files for the full code.