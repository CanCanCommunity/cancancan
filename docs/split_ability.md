# Split the ability file

When the application becomes more complex and many abilities are defined, you might want to start splitting your ability file into multiple files.

We will show here an example on how to split your ability file on a “per-model” basis.

Imagine the following scenario:

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability
  def initialize(user)
    can :edit, User, id: user.id
    can :read, Book, published: true
    can :edit, Book, user_id: user.id
    can :manage, Comment, user_id: user.id
  end
end
```

This is, of course, not too complicated, and in a real world application we would not split this file, but for didactic reasons we want to split this file “per-model”.

We suggest to have an app/abilities folder and create a separate file for each model (exactly as you would do with Pundit).

```ruby
# app/abilities/user_ability.rb
class UserAbility
  include CanCan::Ability
  def initialize(user)
    can :edit, User, id: user.id
  end
end

# app/abilities/comment_ability.rb
class CommentAbility
  include CanCan::Ability
  def initialize(user)
    can :manage, Comment, user_id: user.id
  end
end

# app/abilities/book_ability.rb
class BookAbility
  include CanCan::Ability
  def initialize(user)
    can :read, Book, published: true
    can :edit, Book, user_id: user.id
  end
end
```

Now you can override the `current_ability` method in you controller. For example:

```ruby
# app/controllers/books_controller.rb
class BooksController
  def current_ability
    @current_ability ||= BookAbility.new(current_user)
  end
end
```

Using this technique you have all the power of CanCanCan ability files, that allows you define your permissions with hash of conditions. This means you can check permissions on a single instance of a model, but also retrieve automatically all the instances where you are authorized to perform a certain action.

You can call `can? :read, @book` but also `Book.accessible_by(current_ability, :read)` that will return all the books you can read.

When your controller is executed, it will read only the ability file that you need, saving time and memory.

## Merge ability files

Abilities files can always be merged together, so if you need two of them in one Controller, you can simply:

```ruby
def current_ability
  @current_ability ||= ReadAbility.new(current_user).merge(WriteAbility.new(current_user))
end
```
