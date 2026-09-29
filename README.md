# samplejenkinsweb

## Jenkins Pipeline setup for this static site

This repository includes a root-level `Jenkinsfile` designed for a standard Jenkins agent (no custom Docker image and no privileged runtime needed).

### Prerequisites

- Jenkins Pipeline support
- A Linux/Unix-like agent with `bash`, `grep`, `tar`, and `python3`
- Optional validators: `tidy` (preferred) or `xmllint` for stronger HTML checks
- Jenkins JUnit plugin (for test report visualization)

### Create the Jenkins job

1. In Jenkins, create a **Pipeline** job.
2. Under **Pipeline**, select **Pipeline script from SCM**.
3. Point SCM at this repository and branch.
4. Keep script path as `Jenkinsfile`.
5. Save and run the job.

### What the pipeline stages do

- **Checkout**: checks out source from SCM.
- **Validate HTML**: runs `scripts/validate_html.sh` to verify expected files exist, validate HTML (using `tidy` or `xmllint` when available, with Python parser fallback), and enforce basic quality checks like `<!DOCTYPE html>`, non-empty `<title>`, and non-empty `<h1>`.
- **Test Site Content**: runs `scripts/test_site.sh` to verify expected static content and catch placeholder text.
- **Package Artifacts**: creates `build/static-site.tar.gz` from files listed in `ci/expected-files.txt`.

The pipeline always publishes JUnit reports (`reports/*.xml`) and archives build artifacts/reports so each Jenkins run demonstrates useful outputs.

### Run the same checks locally

From the repository root:

```bash
scripts/validate_html.sh
scripts/test_site.sh
mkdir -p build && tar -czf build/static-site.tar.gz -T ci/expected-files.txt
```
