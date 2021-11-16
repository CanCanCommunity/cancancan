# Abilities in Database

What if you or a client, wants to change permissions without having to re-deploy the application?
In that case, it may be best to store the permission logic in a database: it is very easy to use the database records when defining abilities.

We will need a model called `Permission`.

Each user `has_many :permissions`, and each permission has `action`, `subject_class` and `subject_id` columns. The last of which is optional.

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can do |action, subject_class, subject|
      user.permissions.where(action: aliases_for_action(action)).any? do |permission|
        permission.subject_class == subject_class.to_s &&
          (subject.nil? || permission.subject_id.nil? || permission.subject_id == subject.id)
      end
    end
  end
end
```

An alternative approach is to define a separate `can` ability for each permission.

```ruby
def initialize(user)
  user.permissions.each do |permission|
    if permission.subject_id.nil?
      can permission.action.to_sym, permission.subject_class.constantize
    else
      can permission.action.to_sym, permission.subject_class.constantize, id: permission.subject_id
    end
  end
end
```

The actual details will depend largely on your application requirements, but hopefully, you can see how it's possible to define permissions in the database and use them with CanCanCan.

You can mix-and-match this with defining permissions in the code as well. This way you can keep the more complex logic in the code so you don't need to shoe-horn every kind of permission rule into an overly-abstract database.

You can also create a `Permission` model containing all possible permissions in your app. Use that code to create a rake task that fills a `Permission` table:
(The code below is not fully tested)

To use the following code, the permissions table should have such fields :name, :user_id, :subject_class, :subject_id, :action, and :description.You can generate the permission model by the command: `rails g model Permission user_id:integer name:string subject_class:string subject_id:integer action:string description:text`.

```ruby
class ApplicationController < ActionController::Base
  ...
  protected

  # Derive the model name from the controller. UsersController will return User
  def self.permission
    return name = controller_name.classify.constantize
  end
end
```

```ruby
def setup_actions_controllers_db

  write_permission("all", "manage", "Everything", "All operations", true)

  controllers = Dir.new("#{Rails.root}/app/controllers").entries
  controllers.each do |controller|
    if controller =~ /_controller/
      foo_bar = controller.camelize.gsub(".rb","").constantize.new
    end
  end
  # You can change ApplicationController for a super-class used by your restricted controllers
  ApplicationController.subclasses.each do |controller|
    if controller.respond_to?(:permission)
      klass, description = controller.permission
      write_permission(klass, "manage", description, "All operations")
      controller.action_methods.each do |action|
        if action.to_s.index("_callback").nil?
          action_desc, cancan_action = eval_cancan_action(action)
          write_permission(klass, cancan_action, description, action_desc)
        end
      end
    end
  end

end


def eval_cancan_action(action)
  case action.to_s
  when "index", "show", "search"
    cancan_action = "read"
    action_desc = I18n.t :read
  when "create", "new"
    cancan_action = "create"
    action_desc = I18n.t :create
  when "edit", "update"
    cancan_action = "update"
    action_desc = I18n.t :edit
  when "delete", "destroy"
    cancan_action = "delete"
    action_desc = I18n.t :delete
  else
    cancan_action = action.to_s
    action_desc = "Other: " << cancan_action
  end
  return action_desc, cancan_action
end

def write_permission(class_name, cancan_action, name, description, force_id_1 = false)
  permission = Permission.find(:first, :conditions => ["subject_class = ? and action = ?", class_name, cancan_action])
  if not permission
    permission = Permission.new
    permission.id = 1 if force_id_1
    permission.subject_class = class_name
    permission.action = cancan_action
    permission.name = name
    permission.description = description
    permission.save
  else
    permission.name = name
    permission.description = description
    permission.save
  end
end
```
