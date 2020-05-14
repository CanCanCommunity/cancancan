An ability rule will override a previous one. 
For example, let's say we want the user to be able to do everything to projects except destroy them. 

This is the correct way:

```ruby
can :manage, Project
cannot :destroy, Project
```

It is important that the `cannot :destroy` line comes after the `can :manage` line. If they were reversed, `cannot :destroy` would be overridden by `can :manage`.

Adding `can` rules do not override prior rules, but instead are logically or'ed.

```ruby
can :manage, Project, user_id: user.id
can :update, Project do |project|
  !project.locked?
end
```

For the above, `can? :update` will always return true if the `user_id` equals `user.id`, even if the project is locked. 

This is also important when dealing with roles which have inherited behavior. For example, let's say we have two roles, moderator and admin. We want the admin to inherit the moderator's behavior.

```ruby
if user.role? :moderator
  can :manage, Project
  cannot :destroy, Project
  can :manage, Comment
end

if user.role? :admin
  can :destroy, Project
end
```

Here it is important the admin role be after the moderator so it can override the `cannot` behavior to give the admin more permissions. See [[Role Based Authorization]].

If you are not getting the behavior you expect, please [[post an issue|https://github.com/CanCanCommunity/cancancan/issues]].

## Additional Docs

* [[Defining Abilities]]
* [[Checking Abilities]]
* [[Debugging Abilities]]
* [[Testing Abilities]]