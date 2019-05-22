# artsy/node

This node contains shared [executors](orb-executors) to be used across our node projects.

## Usage example

To reuse the `build` executor

```yaml
# In your project's .circleci/config.yml

# Using the volatile label is _not_ recommended.
# Use the version in the comment at the top of node.yml instead.

orbs:
  node: artsy/node@volatile

jobs:
  build:
    executors: node/build
    steps:
      # ... add steps here
```

[orb-executors]: https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-executors
