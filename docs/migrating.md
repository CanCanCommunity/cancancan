# Migration Guide

## From 2.x to 3.x

### Breaking changes

- **Defining abilities without a subject is not allowed anymore.**
  For example, `can :dashboard` is not going to be accepted anymore and will raise an exception.
  All these kind of rules need to be rethought in terms of `can action, subject`. `can :read, :dashboard` for example.

- **Eager loading is not automatic.** If you relied on CanCanCan to avoid N+1 queries, this will not be the case anymore.
  From now on, all necessary `includes`, `preload` or `eager_load` need to be explicitly written. We strongly suggest to have
  `bullet` gem installed to identify your possible N+1 issues.

- **Use of distinct.** Uniqueness of the results is guaranteed by using the `distinct` clause in the final query.
  This may cause issues with some existing queries when using clauses like `group by` or `order` on associations.
  Adding a custom `select` may be necessary in these cases.

- **aliases are now merged.** When using the method to merge different Ability files, the aliases are now also merged. This might cause some incompatibility issues.
