# Check abilities - Avoid common mistakes

You now know that you can use the `can?` method in the controller or view to check the user's permission for a given action and object.

```ruby
can? :destroy, @article
```

and also that the `cannot?` method is for convenience and performs the opposite check of `can?`

```ruby
cannot? :destroy, @article
```

What we want to explain you in this chapter is that you can also pass the class instead of a single instance:

```erb
<% if can? :create, Project %>
  <%= link_to "New Project", new_project_path %>
<% end %>
```

It's important to note here that if a block or hash of conditions exist they will be ignored when checking on a class, and it will return `true`. For example:

```ruby
can :read, Project, priority: 3
can? :read, Project # returns true
```

It is impossible to answer this `can?` question completely because not enough detail is given. Here the class does not have a `priority` attribute to check on.

Think of it as asking

> can the current user read **a** project?"

The user can read a project, so this returns `true`. However it depends on which specific project you're talking about.

If you are doing a class check, it is important you do another check once an instance becomes available so the hash of conditions can be used.

The reason for this behavior is because of the controller `index` action. Since the `authorize_resource` before filter has no instance to check on, it will use the `Project` class. If the authorization failed at that point then it would be impossible to filter the results later when [Fetching Records](./fetching_records.md).

That is why passing a class to `can?` will return `true`.

The code answering the question "can the user update all the articles?" would be something like:

```ruby
Article.accessible_by(current_ability).count == Article.count
```
