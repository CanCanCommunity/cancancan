# Inherited Resources

**This guide is for cancancan < 2.0 only.
If you want to use Inherited Resources and cancancan 2.0 please check for extensions like [cancan-inherited_resources](https://github.com/TylerRick/cancan-inherited_resources).

The `load_and_authorize_resource` call will automatically detect if you are using [Inherited Resources](https://github.com/activeadmin/inherited_resources) and load the resource through that. The `load` part in CanCan is still necessary since Inherited Resources does lazy loading. This will also ensure the behavior is identical to normal loading.

```ruby
class ProjectsController < InheritedResources::Base
  load_and_authorize_resource
end
```

if you are doing nesting you will need to mention it in both Inherited Resources and CanCan.

```ruby
class TasksController < InheritedResources::Base
  belongs_to :project
  load_and_authorize_resource :project
  load_and_authorize_resource :task, :through => :project
end
```

<i>Please note that even for a `has_many :tasks` association, the `load_and_authorize_resource` needs the singular name of the associated model...</i>

**Warning**: when overwriting the `collection` method in a controller the `load` part of a `load_and_authorize_resource` call will not work correctly. See <https://github.com/ryanb/cancan/issues/274> for the discussions.

In this case you can override collection like

```ruby
skip_load_and_authorize_resource :only => :index

def collection
  @products ||= end_of_association_chain.accessible_by(current_ability).paginate(:page => params[:page], :per_page => 10)
end
```

## Mongoid

With mongoid it is necessary to reference `:project_id` instead of just `:project`

```ruby
class TasksController < InheritedResources::Base
  ...
  load_and_authorize_resource :task, :through => :project_id
end
```
