# SQL Strategies

When [fetching records](./fetching_records.md) from the database, CanCanCan generates the SQL for you.

The generated SQL, although correct, might not be performant.

In the history of CanCanCan we had many issues with different versions of the generated SQL and we finally reached to the conclusion that there's no single solutions that fits all the needs.

That's why in the latest versions of CanCanCan, you are given the possibility to customize how the SQL is generated and choose from multiple options.

You can customize the SQL strategy globally with:

```ruby
# config/initializers/cancancan.rb

CanCan.accessible_by_strategy = :subquery # :left_join is the default
```

or on a single `accessible_by` call:

```ruby
Article.accessible_by(current_ability, strategy: :subquery) # :left_join is, again, the default
```

or on a group of queries:

```ruby
CanCan.with_accessible_by_strategy(:subquery) do
  Article.accessible_by(current_ability)
  # ...
end
```

Here is a complete list of the available strategies, explained by examples.

Given the following permissions:

```ruby
can :read, Article, mentions: { user: { name: u.name } }
```

## :left_join

Note that in the default strategy, we use the `DISTINCT` clause which might cause performance issues.

```sql
SELECT DISTINCT "articles".*
FROM "articles"
LEFT OUTER JOIN "mentions" ON "mentions"."article_id" = "articles"."id"
LEFT OUTER JOIN "users" ON "users"."id" = "mentions"."user_id"
WHERE "users"."name" = 'pippo'
```

## :subquery

By using the `:subquery` strategy, the `DISTINCT` clause can be removed.

```sql
SELECT "articles".*
FROM "articles"
WHERE "articles"."id" IN
  (SELECT "articles"."id"
   FROM "articles"
   LEFT OUTER JOIN "mentions" ON "mentions"."article_id" = "articles"."id"
   LEFT OUTER JOIN "users" ON "users"."id" = "legacy_mentions"."user_id"
   WHERE "users"."name" = 'pippo')
```
