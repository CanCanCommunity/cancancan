You can use CanCan with controllers that do not follow the traditional show/new/edit/destroy actions, however you should not use the `load_and_authorize_resource` method since there is no resource to load. Instead you can call `authorize!` in each action separately.

**NOTE:** This is **not** the same as having additional non-RESTful actions on a RESTful controller. See the Choosing Actions section of the [[Authorizing Controller Actions]] page for details.

For example, let's say we have a controller which does some miscellaneous administration tasks such as rolling log files. We can use the `authorize!` method here.

```ruby
class AdminController < ActionController::Base
  def roll_logs
    authorize! :roll, :logs
    # roll the logs here
  end
end
```

And then authorize that in the `Ability` class.

```ruby
can :roll, :logs if user.admin?
```

Notice you can pass a symbol as the second argument to both `authorize!` and `can`. It doesn't have to be a model class or instance. Generally the first argument is the "action" one is trying to perform and the second argument is the "subject" the action is being performed on. It can be anything.

## Alternative: authorize_resource

Alternatively you can use the `authorize_resource` and specify that there's no class. This way it will pass the resource symbol instead. This is good if you still have a Resource-like controller but no model class backing it.

```ruby
class ToolsController < ApplicationController
  authorize_resource :class => false
  def show
    # automatically calls authorize!(:show, :tool)
  end
end
```