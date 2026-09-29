pipeline {
  agent any

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Validate HTML') {
      steps {
        sh 'scripts/validate_html.sh'
      }
    }

    stage('Test Site Content') {
      steps {
        sh 'scripts/test_site.sh'
      }
    }

    stage('Package Artifacts') {
      steps {
        sh '''
          set -euo pipefail
          mkdir -p build
          tar -czf build/static-site.tar.gz -T ci/expected-files.txt
        '''
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'reports/*.xml'
      archiveArtifacts artifacts: 'build/**,reports/**,ci/**,Jenkinsfile,scripts/*.sh', fingerprint: true, allowEmptyArchive: true
      sh 'rm -rf .ci-tmp build reports'
    }
  }
}
