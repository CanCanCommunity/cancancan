Let's say the ability of one action depends on the ability of another. For example, what if we have a `Project` which `has_many :tasks` and we want a task's update ability to be dependent on whether the user can update the project. We can perform the `can?` call within the ability definition to check the project permission.

```ruby
can :update, Task do |task|
  can?(:update, task.project)
end
```

With this it is easy to define one ability based on another.