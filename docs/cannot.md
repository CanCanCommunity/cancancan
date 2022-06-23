# Cannot

Yes, sometimes you might need to **remove** permissions. Even if we said that CanCanCan assumes that by default no one has access to any resource, there are situations where you might need to remove an ability.

The `cannot` method takes the same arguments as `can` and defines which actions the user is unable to perform. This is normally done after a more generic `can` call.

```ruby
can :manage, Project
cannot :destroy, Project
```

will allow the user to do **any** action but destroy the project.

Of course, there's a `cannot?` method to check abilities that is a simple alias for `!can?`.
