# samplejenkinsweb

Static HTML site packaged as a Maven WAR for Jenkins.

## Local build

```bash
mvn clean package
```

Expected artifact:

- `target/samplejenkinsweb-1.0.0-SNAPSHOT.war`

## Jenkins setup

This repository includes a `Jenkinsfile` for a standard Jenkins agent with Maven and Java installed.

Pipeline behavior:

- Runs `mvn -B clean package`
- Publishes Maven test reports from `target/surefire-reports/*.xml`
- Archives WAR artifacts from `target/*.war`
