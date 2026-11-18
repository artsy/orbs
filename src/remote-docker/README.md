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
`$CIRCLE_SHA1<tag_suffix>`, where `tag_suffix` defaults to `-<target>` when a
target is set (like the BuildKit jobs above). Needs the `hokusai` context (AWS credentials).

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
          build_args: BUNDLE_GITHUB__COM
```
