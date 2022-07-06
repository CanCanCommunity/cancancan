# Combine abilities

It is possible to define multiple abilities for the same resource. Here the user will be able to read projects which are released OR available for preview.

```ruby
can :read, Project, released: true
can :read, Project, preview: true
```

The `cannot` method takes the same arguments as `can` and defines which actions the user is unable to perform. This is normally done after a more generic `can` call.

```ruby
can :manage, Project
cannot :destroy, Project
```

The order of these calls is important.

## Abilities precedence

An ability rule will override a previous one.

For example, let's say we want the user to be able to do everything to projects except destroy them.

This is the correct way:

```ruby
can :manage, Project
cannot :destroy, Project
```

It is important that the `cannot :destroy` line comes after the `can :manage` line. If they were reversed, `cannot :destroy` would be overridden by `can :manage`.

Adding `can` rules does not override prior rules, but instead are logically or'ed.

```ruby
can :manage, Project, user: user
can :update, Project, locked: false
```

For the above, `can? :update, @project` will return true if project owner is the user, even if the project is locked.

This is also important when dealing with roles which have inherited behavior. For example, let's say we have two roles, moderator and admin. We want the admin to inherit the moderator's behavior.

```ruby
if user.moderator?
  can :manage, Project
  cannot :destroy, Project
  can :manage, Comment
end

if user.admin?
  can :destroy, Project
end
```

Here it is important for the admin permissions to be defined after the moderator ones, so it can override the `cannot` behavior to give the admin more permissions.

Let's now check at a different way of defining abilities: [blocks](./define_abilities_with_blocks.md).
