# artsy/skip-wip-ci

This node contains shared commands and jobs that hit Github's API and skips draft PRs or PRs with "\[wip\]", "\[skip ci\]", or "\[ci skip\]" in title.

## Usage example

To use the `check-skippable-pr` job

```yaml
# In your project's .circleci/config.yml

# Using the volatile label is _not_ recommended.
# Use the version in the comment at the top of node.yml instead.

orbs:
  skip-wip-ci: artsy/skip-wip-ci@volatile

workflows:
  default:
    jobs:
      - skip-wip-ci/check-skippable-pr
      - test:
          <<: *not_staging_release
```

skip-wip-ci will run in parallel to test and cancel the test job if criteria is met
