# Internationalization

To use translations in your app define some yaml like this:

```yaml
# en.yml
en:
  unauthorized:
    manage:
      all: "You have no access to this resource"
```

## Translation for individual abilities

If you want to customize messages for some model or even for some ability, define translation like this:

```ruby
# models/ability.rb
...
can :create, Article
...
```

```yaml
# en.yml
en:
  unauthorized:
    create:
      article: "Only an admin can create an article"
```

### Translating custom abilities

Also translations is available for your custom abilities:

```ruby
# models/ability.rb
...
can :vote, Article
...
```

```yaml
# en.yml
en:
  unauthorized:
    vote:
      article: "Only users which have one or more article can vote"
```

## Variables for translations

Finally you may use `action`(which contain ability like 'create') and `subject`(for example 'article') variables in your translation:

```yaml
# en.yml
en:
  unauthorized:
    manage:
      all: "You do not have access to %{action} %{subject}!"
```
