Let's say we have nested resources set up in our routes.

```ruby
resources :projects do
  resources :tasks
end
```

We can then tell CanCanCan to load the project and then load the task through that.

```ruby
class TasksController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, through: :project
end
```

This will fetch the project using `Project.find(params[:project_id])` on every controller action, save it in the `@project` instance variable, and authorize it using the `:read` action to ensure the user has the ability to access that project. If you don't want to do the authorization you can simply use `load_resource`, but calling just `authorize_resource` for the parent object is insufficient. The task is then loaded through the `@project.tasks` association.

If the name of the association doesn't match the resource name, for instance `has_many :issues, class_name: 'Task'`, you can specify the association name using `:through_association`.

```ruby
  class TasksController < ApplicationController
    load_and_authorize_resource :project
    load_and_authorize_resource :task, through: :project, through_association: :issues
  end
```

If the resource name (`:project` in this case) does not match the controller then it will be considered a parent resource. You can manually specify parent/child resources using the `parent: false` option.


## Nested through method

It's also possible to nest through a method, this is commonly the `current_user` method.

```ruby
class ProjectsController < ApplicationController
  load_and_authorize_resource through: :current_user
end
```

Here everything will be loaded through the `current_user.projects` association.

## Shallow nesting

The parent resource is required to be present and it will raise an exception if the parent is ever `nil`. 
If you want it to be optional (such as with shallow routes), add the `shallow: true` option to the child.

```ruby
class TasksController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, through: :project, shallow: true
end
```

## Singleton resource

What if each project only had one task through a `has_one` association? To set up singleton resources you can use the `:singleton` option.

```ruby
class TasksController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, through: :project, singleton: true
end
```

It will then use the `@project.task` and `@project.build_task` methods for fetching and building respectively.

## Polymorphic associations

Let's say tasks can either be assigned to a Project or an Event through a polymorphic association. An array can be passed into the `:through` option and it will use the first one it finds.

```ruby
load_resource :project
load_resource :event
load_and_authorize_resource :task, through: [:project, :event]
```

Here it will check both the `@project` and `@event` variables and fetch the task through whichever one exists. Note that this is only loading the parent model, if you want to authorize the parent you will need to do it through a before_action because there is special logic involved.

```ruby
before_action :authorize_parent

private

def authorize_parent
  authorize! :read, (@event || @project)
end
```

## Accessing parent in ability

Sometimes the child permissions are closely tied to the parent resource. For example, if there is a `user_id` column on Project, one may want to only allow access to tasks if the user owns their project.

This will happen automatically due to the `@project` instance being authorized in the nesting. However it's still a good idea to restrict the tasks separately. You can do so by going through the project association.

```ruby
# in Ability
can :manage, Task, project: { user_id: user.id }
```

This means you will need to have a project tied to the tasks which you pass into here. For example, if you are checking if the user has permission to create a new task, do that by building it through the project.

```ruby
can? :create, @project.tasks.build
```

It's also possible to check permission through an association like this.

```ruby
can? :read, @project => Task
```

This will use the above `:project` hash conditions and ensure `@project` meets those conditions.

## Has_many through associations
How to load and authorize resources with a has_many :through association?

Given that situation:

```ruby
class User < ActiveRecord::Base
  has_many :groups_users
  has_many :groups, through: :groups_users
end
```

```ruby
class Group < ActiveRecord::Base
  has_many :groups_users
  has_many :users, through: :groups_users
end
```

```ruby
class GroupsUsers < ActiveRecord::Base
  belongs_to :group, inverse_of: :groups_users
  belongs_to :user, inverse_of: :groups_users
end
```

and in the controller:

```ruby
class UsersController < ApplicationController
  load_and_authorize_resource :group
  load_and_authorize_resource through: :group
```

in ability.rb

```ruby
can :create, User, groups_users: {group: {CONDITION_ON_GROUP} }
```

Don't forget the **inverse_of** option, is the trick to make it works correctly. 

Remember to define the ability through the **groups_users** model (i.e. don't write `can :create, User, groups: {CONDITION_ON_GROUP}`)

You will be able to persist the association just calling `@user.save` instead of `@group.save`
