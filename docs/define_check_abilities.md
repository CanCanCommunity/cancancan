# Define and Check abilities

CanCanCan is an authorization library and therefore the first and most interesting thing to learn is how to define and check abilities. During the [installation](./installation.md) you generated an `ability.rb` file but you don't know yet how to use it.

There are two basic methods in CanCanCan that you will use:

```ruby
can actions, subjects, conditions
# without the question mark
```

is how you define who can **perform** certain `actions` on certain `subjects`.

```ruby
can? action, subject
```

will be the method that you will use to **check** if the user is authorized to perform a certain `action` on a certain `subject`.

We don't want to be too abstract here so let's start with a very concrete example.

> We have a blog with articles and the first thing you want to control is "who can edit an article?"

```ruby
class Article
  belongs_to :user
end
```

The answer to this question is that

> "only the author can edit an article."

We can define the permissions in the `ability.rb`:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :update, Article, user: user
  end
end

# from here on we will skip the ability.rb file structure
```

And we can easily check with the following call:

```ruby
@article = Article.find(params[:id])

can? :update, @article # => true
```

But how does CanCanCan know who is the `user`?
When you use the `can?` method in a Rails controller or view, CanCanCan expects that there's a `current_user` method defined. So if you are using something like [devise](https://github.com/heartcombo/devise) for your authentication, you don't need to do anything special.

By default, CanCanCan assumes no permissions: no one can do any action on any object.

`can :update, Article, user: user` is stating that the user can update an article, if it is its author.

Regarding the `Article` there are actually more permissions to check:

- who can read them?
- what can the administrator do?

A complete example looks like the following:

```ruby
can :read, Article, published: true

return unless user.present?

can :read, Article, user: user
can :update, Article, user: user

return unless user.admin?

can :read, Article
can :update, Article
```

The code above is stating the following:

- users that are not logged in, can read published articles
- logged in users can **also** read and update their own articles
- administrators can read and update all the articles.

> CanCanCan works, at its best, when defining increasing permissions.

The code above can be simplified like this:

```ruby
can :read, Article, published: true

return unless user.present?

can [:read, :update], Article, user: user

return unless user.admin?

can [:read, :update], Article
```

Now that we know the basics of defining and checking abilities, let's check what are the possible actions.

## Can Actions

CanCanCan offers four aliases: `:read`, `:create`, `:update`, `:destroy` for the actions. These aren't the same as the seven Restful actions in Rails. CanCanCan automatically adds some convenient aliases for mapping the controller actions.

```ruby
read: [:index, :show]
create: [:new, :create]
update: [:edit, :update]
destroy: [:destroy]
```

this means that when you define `can :read, Article`, you can also check:

```ruby
can? :show, @article
```

when you define `can :update, Article`, you can also check:

```ruby
can? :edit, @article
```

This will be very convenient when we will authorize the Rails Controller actions.

For now, what you need to know, is that these four will be your most used, basic actions.

One last action is `manage`. This action means that you have full permissions on the subject and you can perform any possible action. Knowing that, we can now rewrite our ability.rb example:

```ruby
can :read, Article, published: true

return unless user.present?

can [:read, :update], Article, user: user

return unless user.admin?

can :manage, Article
```

and say that the administrators are able to perform any action on the articles.

```ruby
can? :edit, @article # => true
can? :destroy, @article # => true
```

Now that we learned about actions and their aliases let's see what we can do with the subjects

## Can subjects

The subject of an action is usually a Ruby class. Most of the times you want to define your permissions on specific classes, but this is not your only option.

You can actually use any subject, and one of the most common cases is to just use a symbol.
An admin dashboard could be protected by defining:

```ruby
can :read, :admin_dashboard
```

and checked with `can? :read, :admin_dashboard`.

One special symbol is `:all`. All will allow an action on all possible subjects.

In our example, it would not be uncommon to see the following:

```ruby
can :read, Article, published: true

return unless user.present?

can [:read, :update], Article, user: user

return unless user.admin?

can :manage, :all
```

and give all possible permissions to the administrator.

Note that the code above allows the administrator to also `:read, :admin_dashboard`. `:manage` means literally **any** action, not only CRUD ones.

> You **must and should** always check for specific permissions, but you don't need to define all of them if not needed.

If at some point you have a new page reserved to the administrators, where they can translate articles, you should check for `can? :translate, @article`, but you don't need to define the ability, since the administrators can already do any action. It will be easy in the future to give the possibility for authors to translate their own articles by changing your permissions file:

```ruby
can :read, Article, published: true

return unless user.present?

can [:read, :update, :translate], Article, user: user

return unless user.admin?

can :manage, :all
```

## Checking other users abilities

What if you want to determine the abilities of a `User` record that is not the `current_user`? Maybe we want to see if another user can update an article.

```ruby
Ability.new(some_user).can? :update, @article
```

You can also add an `ability` method in the `User` model and delegate the `can?` method:

```ruby
# app/models/user.rb
class User
  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end
end

some_user.can? :update, @article
```

That's everything you need to know about checking abilities. The DSL is very easy but yet very powerful. However, there is still a lot you should learn about defining abilities. You can [dig deeper](./hash_of_conditions.md) now, but we would suggest to stop, digest, and proceed on a more Rails-specific topic: [Controller helpers](./controller_helpers.md) where you will learn how to secure your Rails application.

Or you could already take a look at the session about [testing](./testing.md).
