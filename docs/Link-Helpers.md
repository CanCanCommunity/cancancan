Generally you only want to show new/edit/destroy links when the user has permission to perform that action. You can do so like this in the view.

```rhtml
<% if can? :update, @project %>
  <%= link_to "Edit", edit_project_path(@project) %>
<% end %>
```

However if you find yourself repeating this pattern often you may want to add helper methods like this.

```ruby
# in ApplicationHelper
def show_link(object, content = "Show")
  link_to(content, object) if can?(:read, object)
end

def edit_link(object, content = "Edit")
  link_to(content, [:edit, object]) if can?(:update, object)
end

def destroy_link(object, content = "Destroy")
  link_to(content, object, :method => :delete, :confirm => "Are you sure?") if can?(:destroy, object)
end

def create_link(object, content = "New")
  if can?(:create, object)
    object_class = (object.kind_of?(Class) ? object : object.class)
    link_to(content, [:new, object_class.name.underscore.to_sym])
  end
end
```

Then a link is as simple as this.

```rhtml
<%= edit_link @project %>
```

I only recommend doing this if you see this pattern a lot in your application. There are times when the view code is more complex where this doesn't fit well.