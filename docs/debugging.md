# Debugging Abilities

What do you do when permissions you defined in the Ability class don't seem to be working properly?

Have you already read the [Testing](./testing.md) section? You can now try to reproduce this problem in the `rails console`.

## Debugging Member Actions

```ruby
# in rails console or test
user = User.first # fetch any user you want to test abilities on
project = Project.first # any model you want to test against
ability = Ability.new(user)
ability.can?(:create, project) # see if it returns the expected behavior for that action
```

Note: this assumes that the model instance is being loaded properly. If you are only using `authorize_resource` it will not have an instance to work with so it will use the class.

```ruby
ability.can?(:create, Project)
```

## Debugging `index` Action

```ruby
# in rails console or test
user = User.first # fetch any user you want to test abilities on
ability = Ability.new(user)
ability.can?(:index, Project) # see if user can access the class
Project.accessible_by(ability) # see if returns the records the user can access
Project.accessible_by(ability).to_sql # see what the generated SQL looks like to help determine why it's not fetching the records you want
```

If you find it is fetching the wrong records in complex cases, you may need to use an SQL condition instead of a hash inside the Ability class.

```ruby
can :update, Project, ["priority < ?", 3] do |project|
  project.priority < 3
end
```

## Logging AccessDenied Exception

If you think the `CanCan::AccessDenied` exception is being raised and you are not sure why, you can log this behavior to help debug what is triggering it.

```ruby
# in ApplicationController
rescue_from CanCan::AccessDenied do |exception|
  Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
  # ...
end
```

## Issue Tracker

If you are still unable to resolve the issue, [open a question on Stackoverflow](https://stackoverflow.com/questions/ask?tags=cancancan) with tag
[cancancan](https://stackoverflow.com/questions/tagged/cancancan).
