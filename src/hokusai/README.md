# artsy/hokusai

This orb is built to share hokusai configuration across many CircleCI setups. It currently provides CirclCI workflow steps for `test`, `deploy-staging` and `deploy-production`, using a PR-based release process. Use the latest version of this orb in your app to ensure that hokusai and all related libs are up to date, and that deployments use the latest recommended workflow.

Enabling orbs requires CircleCI 2.1, which is enabled for an app in 2 steps: 
- In CircleCI UI > App "Build Settings" > "Advanced Settings", turn the "Enable pipelines" radio to `true`.
- In the app's `.circleci/config.yml`, set `version: 2.1` at the top of the file. 

To use the orb, within your app's `.circleci/config.yml`, use the hokusai orb for one or all workflow steps. It is recommended to use the orb for all steps, but implementation will depend on a particular app's needs.

See these example PR's for implementation:
- [Use Orb for all steps](https://github.com/artsy/metaphysics/pull/1713/files)
- [Use Orb for some steps](https://github.com/artsy/positron/pull/2014/files )
