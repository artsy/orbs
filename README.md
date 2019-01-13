# Orbs

CircleCI orbs used at Artsy

## What's an Orb?

CircleCI 2.1 introduces [several new features](https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/whats-new.md#whats-new-in-21-configuration) to make sharing configuration across projects easier. Straight from their docs:

> Orbs are packages of CircleCI configuration that can be shared across projects. Orbs allow you to make a single bundle of jobs, commands, and executors that can reference each other and can be imported into a CircleCI build configuration and invoked in their own namespace. Orbs are registered with CircleCI, with revisions expressed using the semver pattern.

For more info on Orbs, checkout their [docs](https://github.com/CircleCI-Public/config-preview-sdk/tree/master/docs)!

## Deploying

To deploy a change, increment the version located at the [top of the file](https://github.com/artsy/orbs/blob/master/src/yarn/yarn.yml#L1) and merge.
