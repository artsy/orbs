# artsy/defectdojo

CI-side static analysis (SAST/SCA) for the DefectDojo security pipeline. It
provides a `sast` job that runs Semgrep and OSV-Scanner and, when a DefectDojo
instance is reachable, imports the SARIF reports into one long-lived engagement.

Findings never gate the build. A missing or unreadable report fails the job,
because that means the pipeline itself is broken.

## Usage

```yaml
version: 2.1
orbs:
  defectdojo: artsy/defectdojo@volatile

workflows:
  security:
    jobs:
      - defectdojo/sast:
          context: defectdojo   # optional; provides DEFECTDOJO_URL + DEFECTDOJO_TOKEN
          filters:
            branches:
              ignore: [main, staging, release]
```

## Import behaviour

`import-to-defectdojo` dry-runs by default: it validates each report, prints a
summary and exits 0. It only uploads when **both** environment variables are
present (set them in a CircleCI [context], never in the config):

| Variable | Value |
|---|---|
| `DEFECTDOJO_URL` | DefectDojo base URL (no trailing slash) |
| `DEFECTDOJO_TOKEN` | API v2 token of a user allowed to import scans |

When both are set, each report is uploaded to
`${DEFECTDOJO_URL}/api/v2/reimport-scan/` as product
`product-name` (defaults to `$CIRCLE_PROJECT_REPONAME`) and engagement of the
same name, with `close_old_findings=true`.

[context]: https://circleci.com/docs/contexts/
