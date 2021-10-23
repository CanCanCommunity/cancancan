# Role-based Authorization

CanCanCan is decoupled from how you implement roles in the User model, but how might one set up basic role-based authorization? The pros and cons are described [here](https://github.com/kristianmandrup/cantango/wiki/CanCan-vs-CanTango).

The following approach allows you to simply define the role abilities in Ruby and does not need a role model. Alternatively, [[Separate Role Model]] describes how to define the roles and mappings in a database.

Since there is such a tight coupling between the list of roles and abilities, I recommend keeping the list of roles in Ruby. You can do so in a constant under the User class.

```ruby
class User < ActiveRecord::Base
  ROLES = %i[admin moderator author banned]
end
```

But now, how do you set up the association between the user and the roles? You'll need to decide if the user can have many roles or just one.

## One role per user

If a user can have only one role, it's as simple as adding a `role` string column to the `users` table.

```bash
rails generate migration add_role_to_users role:string
rake db:migrate
```

In your `users_controller.rb` add `:role` to the list of permitted parameters.

```ruby
def user_params
  params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
end
```

If you're using ActiveAdmin don't forget to add `role` to the `user.rb` list of parameters as well

```ruby
  permit_params :name, :email, :role
```

Now you can provide a select-menu for choosing the roles in the view.

```rhtml
<!-- in users/_form.html.erb -->
<%= f.collection_select(:role, User::ROLES, :to_s, lambda{|i| i.to_s.humanize}) %>
```

You may not have considered using `collection_select` when you aren't working with an association, but it will work perfectly. In this case the user will see the humanized name of the role, and the simple lower-cased version will be passed in as the value when the form is submitted.

It's then very simple to determine the role of the user in the Ability class.

```ruby
can :manage, :all if user.role == "admin"
```

## Many roles per user

It is possible to assign multiple roles to a user and store it into a single integer column using a [bitmask](<http://en.wikipedia.org/wiki/Mask_(computing)>). First add a `roles_mask` integer column to your `users` table.

```bash
rails generate migration add_roles_mask_to_users roles_mask:integer
rake db:migrate
```

Next you'll need to add the following code to the User model for getting and setting the list of roles a user belongs to. This will perform the necessary bitwise operations to translate an array of roles into the integer field.

```ruby
# in models/user.rb
def roles=(roles)
  roles = [*roles].map { |r| r.to_sym }
  self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.inject(0, :+)
end

def roles
  ROLES.reject do |r|
    ((roles_mask.to_i || 0) & 2**ROLES.index(r)).zero?
  end
end
```

If you're using devise, don't forget to add `attr_accessible :roles` to your user model or add following to application_controller.rb

```ruby
  before_action :configure_permitted_parameters, if: :devise_controller?
  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :password, :password_confirmation, roles: []) }
  end
```

You can use checkboxes in the view for setting these roles.

```rhtml
<% for role in User::ROLES %>
  <%= check_box_tag "user[roles][#{role}]", role, @user.roles.include?(role), {:name => "user[roles][]"}%>
  <%= label_tag "user_roles_#{role}", role.to_s.humanize %><br />
<% end %>
<%= hidden_field_tag "user[roles][]", "" %>
```

Finally, you can then add a convenient way to check the user's roles in the Ability class.

```ruby
# in models/user.rb
def has_role?(role)
  roles.include?(role)
end

# in models/ability.rb
can :manage, :all if user.has_role? :admin
```

See [[Custom Actions]] for a way to restrict which users can assign roles to other users.

This functionality has also been extracted into a little gem called [role_model](http://rubygems.org/gems/role_model) ([code & howto](http://github.com/martinrehfeld/role_model)).

If you do not like this bitmask solution, see [[Separate Role Model]] for an alternative way to handle this.

## Role Inheritance

Sometimes you want one role to inherit the behavior of another role. For example, let's say there are three roles: moderator, admin, superadmin and you want each one to inherit the abilities of the one before. There is also a "role" string column in the User model. You should create a method in the User model which has the inheritance logic.

```ruby
# in User
ROLES = %w[moderator admin superadmin]
def role?(base_role)
  ROLES.index(base_role.to_s) <= ROLES.index(role)
end
```

You then use this in the Ability class.

```ruby
# in Ability#initialize
if user.role? :moderator
  can :manage, Post
end
if user.role? :admin
  can :manage, ForumThread
end
if user.role? :superadmin
  can :manage, Forum
end
```

Here a superadmin will be able to manage all three classes but a moderator can only manage the one. Of course you can change the role logic to fit your needs. You can add complex logic so certain roles only inherit from others. And if a given user can have multiple roles you can decide whether the lowest role takes priority or the highest one does. Or use other attributes on the user model such as a "banned", "activated", or "admin" column.

This functionality has been extracted into a gem called [canard](http://rubygems.org/gems/canard) ([code & howto](http://github.com/james2m/canard)).

## Alternative Role Inheritance

If you would like to keep the inheritance rules in the Ability class instead of the User model it is easy to do so like this.

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name_to_symbol) }

    if @user.roles.size == 0
      can :read, :all #for guest without roles
    end
  end

  def manager
    can :manage, Employee
  end

  def admin
    manager
    can :manage, Bill
  end
end
```

Here each role is a separate method which is called. You can call one role inside another to define inheritance. This assumes you have a `User#roles` method which returns an array of all roles for that user.
