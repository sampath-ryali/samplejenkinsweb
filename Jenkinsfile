pipeline {
  agent any

  options {
    timestamps()
  }

  stages {
    stage('Build') {
      steps {
        sh 'mvn -B clean package'
      }
    }
  }

  post {
    always {
      junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
      archiveArtifacts artifacts: 'target/*.war', fingerprint: true, onlyIfSuccessful: true
    }
  }
}
