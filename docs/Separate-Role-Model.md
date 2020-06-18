This approach uses a separate role and shows how to setup a many-to-many association, Assignment, between User and Role. Alternatively, [[Role Based Authorization]] describes a simple ruby based approach that defines the roles within ruby.

```ruby
class User < ActiveRecord::Base
  has_many :assignments
  has_many :roles, :through => :assignments
end

class Assignment < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :assignments
  has_many :users, :through => :assignments
end
```

You can assign roles using checkboxes when creating or updating a user model.

```rhtml
<% for role in Role.all %>
<div>
  <%= check_box_tag "user[role_ids][]", role.id, @user.roles.include?(role) %>
  <%=h role.name %>
</div>
<% end %>
<%= hidden_field_tag "user[role_ids][]", "" %>
```

Or you may want to [[use Formtastic|http://railscasts.com/episodes/185-formtastic-part-2]] for this.

Next you need to determine if a user is in a specific role. You can create a method in the User model for this.

```ruby
# in models/user.rb
def has_role?(role_sym)
  roles.any? { |r| r.name.underscore.to_sym == role_sym }
end
```

And then you can use this in your Ability.

```ruby
# in models/ability.rb
def initialize(user)
  user ||= User.new # in case of guest
  if user.has_role? :admin
    can :manage, :all
  else
    can :read, :all
  end
end
```

That's it!

## Role Inheritance Within Ability.rb

You can use the Alternative Role Inheritance strategy described in [[Role Based Authorization|https://github.com/ryanb/cancan/wiki/Role-Based-Authorization]] with one minor modification: change "send(role)" to "send(role.name.downcase)" assuming name is the column describing the role's name in the database. 

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name.downcase) }

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