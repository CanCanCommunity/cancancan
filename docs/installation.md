# Installation

Add this to your Gemfile:

```ruby
gem 'cancancan'
```

and run the `bundle install` command.

Use the provided command to generate a template for your abilities file:

```bash
rails generate cancan:ability
```

This will generate the following file:

```ruby
# /app/models/ability.rb

class Ability
  include CanCan::Ability

  def initialize(user)
  end
end
```

This is everything you need to start. :boom:

All the permissions will be defined in this file.
You can of course split it into multiple files if your application grows, but we'll cover that in a [later chapter](./split_ability.md).

Let's now start with the basic concepts: [define and check abilities](./define_check_abilities.md).
