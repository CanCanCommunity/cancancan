# Defining Abilities: Best Practices

## Use hash conditions as much as possible

Here's why:

**1. Although scopes are fine for fetching, they pose a problem when authorizing a discrete action.**

  For example, this declaration in Ability:

  ```ruby
  can :read, Article, Article.is_published
  ```

  causes this `CanCan::Error`:

  ```
  The can? and cannot? call cannot be used with a raw sql 'can' definition.
  The checking code cannot be determined for :read #<Article ..>.
  ```

  A better way to define the same is:

  ```ruby
  can :read, Article, is_published: true
  ```

**2. Hash conditions are DRYer.**

  By using hashes instead of blocks for all actions, you won't have to worry about translating blocks used for member controller actions (`:create`, `:destroy`, `:update`) to equivalent blocks for collection actions (`:index`, `:show`)—which require hashes anyway!

**3. Hash conditions are OR'd in SQL, giving you maximum flexibilty.**
  
  Every time you define an ability with `can`, each `can` chains together with OR in the final SQL query for that model.

  So if, in addition to the `is_published` condition above, we want to allow authors to see their drafts:

  ```ruby
    can :read, Article, author_id: @user.id, is_published: false
  ```

  Then the final SQL would be:

  ```sql
  SELECT `articles`.*
  FROM   `articles`
  WHERE  `articles`.`is_published` = 1
  OR ( `articles`.`author_id` = 97 AND `articles`.`is_published` = 0 )
  ```

**4. For complex object graphs, hash conditions accommodate `joins` easily.**

  See https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Defining-Abilities.md#hash-of-conditions.

## Give permissions, don't take them away

As I suggested in this [topic on Reddit](https://www.reddit.com/r/ruby/comments/6ytka8/refactoring_cancancan_abilities_brewing_bits/) you should, when possible, give increasing permissions to your users.
CanCanCan increases permissions, it starts by giving no permissions to nobody and then increases those permissions depending on the user. A properly written ability.rb looks like that:

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Post  # start by defining rules for all users, also not logged ones
    return unless user.present?
    can :manage, Post, user_id: user.id # if the user is logged in can manage it's own posts
    can :create, Comment # logged in users can also create comments
    return unless user.manager? # if the user is a manager we give additional permissions
    can :manage, Comment # like managing all comments in the website
    return unless user.admin?
    can :manage, :all # finally we give all remaining permissions only to the admins
  end
end
```

following this good practice will help you to keep your permissions clean and more readable. 

The risk of giving wrong permissions to the wrong users is also decreased.

## Split your ability.rb file

Another help, to make CanCanCan work more in a "pundit way" is to define a separate Ability file for each model, or controller, and then use

```ruby
def current_ability
  @current_ability ||= MyAbility.new(current_user)
end
```

To use a specific ability file: this way you don't have to load the whole ability.rb file on each request.

Abilities files can always be merged together, so if you need two of them in one Controller, you can simply:

```ruby
def current_ability
  @current_ability ||= ReadAbility.new(current_user).merge(WriteAbility.new(current_user))
end
```

You can read more about splitting the Ability file in [this article](https://medium.com/@coorasse/cancancan-that-scales-d4e526fced3d)
