# artsy/remote-docker

This orb establishes a connection with an Artsy-managed remote Docker daemon in
order to run a Docker build in an environment optimized to retain cached Docker
layers.

If the orb is unable to establish a connection with the Artsy-managed remote
Docker daemon, the Docker build will fallback to Circle CI's infrastructure.

This orb requires the following environment variables to be available within the
environment:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

```yaml
# In your project's .circleci/config.yml

# Using the volatile label is _not_ recommended.
# Use the version in the comment at the top of node.yml instead.

orbs:
  artsy-remote-docker: artsy/remote-docker@volatile

workflows:
  default:
    jobs:
      - artsy-remote-docker/build
```

## buildx-build-push

Builds and pushes in one job on CircleCI remote Docker, with a BuildKit cache
stored in the project's ECR repo (tag `buildcache-<target>`). The image tag is
`$CIRCLE_SHA1-<target>`, or `$CIRCLE_SHA1` with no target (like the BuildKit jobs
above). Omit `target` for the image you deploy: hokusai deploys `$CIRCLE_SHA1`.
Needs the `hokusai` context (AWS credentials).

The cache tag is shared by all branches, so the last build to push wins. A branch
with different dependencies may build cold the first time after another branch pushes.

```yaml
workflows:
  default:
    jobs:
      - artsy-remote-docker/buildx-build-push:
          name: tester-image-push
          context: [bundle-github, hokusai]
          target: tester
          secrets: BUNDLE_GITHUB__COM
```

Pass tokens with `secrets`, not `build_args`. A build arg is recorded in the image
history, a secret is not. `secrets` lists job environment variable names; each is
passed as `--secret id=NAME,env=NAME`. In the Dockerfile:

```dockerfile
RUN --mount=type=secret,id=BUNDLE_GITHUB__COM,env=BUNDLE_GITHUB__COM bundle install
```
