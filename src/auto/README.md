# artsy/auto

This orb controls Artsy's package deployment process. It builds off of [a simple community orb](https://github.com/auto-it/orbs/blob/master/src/release/release.yml) that's itself a simple wrapper for [intuit's auto](https://github.com/intuit/auto).

If you're making a generic change about how `auto` executes, it's recommended you do that [upstream](https://github.com/auto-it/orbs/blob/master/src/release/release.yml). If you're actually changing something specific to how Artsy deploys, then this is the right place for it.

## npm trusted publishing

Since 3.0.0 the `publish` and `publish-canary` jobs run on Node 22 with npm 11 and request a CircleCI OIDC token (`NPM_ID_TOKEN`) for [npm trusted publishing](https://docs.npmjs.com/trusted-publishers). npm tries OIDC first and falls back to `NPM_TOKEN`, so a package without a trusted publisher keeps publishing with the token.

To set up a package (npm >= 11.15.0, logged in with publish rights and 2FA):

```sh
npm trust circleci <package> \
  --org-id <circleci-org-id> --project-id <project-id> \
  --pipeline-definition-id <pipeline-definition-id> \
  --vcs-origin github.com/artsy/<repo> \
  --context-id <npm-deploy-context-id> --allow-publish
```

If you override `node-version`, it must be >= 22.14. The job fails early otherwise.

Monorepos publish through `lerna publish`, not `npm publish`, and only lerna >= 10 supports CircleCI trusted publishing. On an older lerna the package keeps publishing with `NPM_TOKEN`.

### Debugging

npm logs OIDC failures only at verbose level and then falls back to `NPM_TOKEN`. Once `NPM_TOKEN` is gone, a misconfigured trusted publisher shows up as a plain `E401`/`E404`. Set `NPM_CONFIG_LOGLEVEL=verbose` on the job to see why the OIDC exchange failed.
