# artsy/defectdojo

CI-side static analysis (SAST/SCA) for the DefectDojo security pipeline. It
provides a `sast` job that runs Semgrep and OSV-Scanner and stores the SARIF
reports (`reports/semgrep.sarif`, `reports/osv.sarif`) as job artifacts.

Findings never gate the build. A scanner error fails the job.

## Usage

```yaml
version: 2.1
orbs:
  defectdojo: artsy/defectdojo@volatile

workflows:
  security:
    jobs:
      - defectdojo/sast
```

The job does not upload anything; importing into DefectDojo happens elsewhere.
