# Orbs

CircleCI orbs used at Artsy

## What's an Orb?

CircleCI 2.1 introduces [several new features](https://github.com/CircleCI-Public/config-preview-sdk/blob/master/docs/whats-new.md#whats-new-in-21-configuration) to make sharing configuration across projects easier. Straight from their docs:

> Orbs are packages of CircleCI configuration that can be shared across projects. Orbs allow you to make a single bundle of jobs, commands, and executors that can reference each other and can be imported into a CircleCI build configuration and invoked in their own namespace. Orbs are registered with CircleCI, with revisions expressed using the semver pattern.

For more info on Orbs, checkout their [docs](https://github.com/CircleCI-Public/config-preview-sdk/tree/master/docs)!

(The TL;DR is there's an `orb` yml configuration file that's used to share things like [executors](orb-executors), [commands](orb-commands), and [jobs](orb-jobs) across your CircleCi builds.)

## Getting Started

All our orbs are `.yml` files that are stored in `src/<orb-name>/<orb-name>.yml`. The nested directory is so that every orb can have associated documentation beside it.

## Versioning

Every orb has a comment like `# Orb Version 1.2.3` on the first line of the file. This comment is significant in that it's used to determine which version of the orb should be deployed (which will be discussed in the next section). Every orb in master will have a comment representing the currently deployed production version.

When you make a change to an orb file you _must_ update the version. CI checks will fail otherwise.

## Deploying

There are two types of deployments that happen in this repo.

1. Canary deployments that happen on every PR change
2. Production deployments that happen when a PR is merged to master.

When you make a change to an orb (and update the version) a canary version will be published. Check the build logs for the version name. This canary build can be used (before your PR is merged to master) to test orb changes in other projects. It's _highly_ recommended that you utilize this canary system to test changes that may impact many projects.

Upon merging a PR, CI will publish the changed orbs to CircleCI's public registry. Artsy also has [renovate configuration](reno-config) to update orb changes across Artsy's GitHub org.

The deployment process is driven by a set of bash scripts in the `scripts` directory. `publish_orbs.sh` is responsible for publishing both the canary and release version of the orbs. It's heavily commented and you're encouraged to read through it if you're interested in how the process works.

[orb-executors]: https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-executors
[orb-commands]: https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands
[orb-jobs]: https://circleci.com/docs/2.0/reusing-config/#authoring-reusable-commands
[reno-config]: https://github.com/artsy/renovate-config/blob/f8d47916b38096ebf834985e926253dcc0f78e25/lib/config-builder.js#L55-L62
