When you define a user's abilities for a given model, you are not restricted to the 7 RESTful actions (create, update, destroy, etc.), you can create your own.

For example, in [[Role Based Authorization]] I showed you how to define separate roles for a given user. However, you don't want all users to be able to assign roles, only admins. How do you set these fine-grained controls? Well you need to come up with a new action name. Let's call it `assign_roles`.

```ruby
# in models/ability.rb
can :assign_roles, User if user.admin?
```

We can then check if the user has permission to assign roles when displaying the role checkboxes and assigning them.

```rhtml
<!-- users/_form.html.erb -->
<% if can? :assign_roles, @user %>
  <!-- role checkboxes go here -->
<% end %>
```

```ruby
# users_controller.rb
def update
  authorize! :assign_roles, @user if params[:user][:assign_roles]
  # ...
end
```

Now only admins will be able to assign roles to users.