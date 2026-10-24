pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 30, unit: 'MINUTES')
  }

  parameters {
    booleanParam(
      name: 'SKIP_DEPLOY',
      defaultValue: false,
      description: 'Validate the checkout only. Do not recreate the edge.'
    )
    string(
      name: 'PUBLIC_APP_URL',
      defaultValue: 'https://play.doxstation.com',
      description: 'Play hostname used for the TLS check. Other vhosts are baked into nginx/.'
    )
    string(
      name: 'WEB_HOST_PORT',
      defaultValue: '3010',
      description: 'AI Code Player UI host port. This job does not restart that app.'
    )
    string(
      name: 'API_HOST_PORT',
      defaultValue: '8010',
      description: 'AI Code Player API host port. This job does not restart that app.'
    )
  }

  environment {
    EDGE_COMPOSE_PROJECT_NAME = 'doxstation'
    IMAGE_TAG = 'latest'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh '''
          echo "Branch: ${GIT_BRANCH:-unknown}"
          echo "Commit: ${GIT_COMMIT:-unknown}"
          git rev-parse --short HEAD || true
          echo "=== Workspace files ==="
          ls -la
          test -f Jenkinsfile || { echo "ERROR: Jenkinsfile missing"; exit 1; }
          test -f docker-compose.yml || { echo "ERROR: docker-compose.yml missing"; exit 1; }
          test -f nginx/Dockerfile || { echo "ERROR: nginx/Dockerfile missing"; exit 1; }
          test -f nginx/default.conf || { echo "ERROR: nginx/default.conf missing"; exit 1; }
          test -f scripts/deploy.sh || { echo "ERROR: scripts/deploy.sh missing"; exit 1; }
        '''
      }
    }

    stage('Detect Tools') {
      steps {
        sh '''
          echo "=== Agent tools ==="
          docker --version
          docker compose version
          echo "WORKSPACE=${WORKSPACE}"
          echo "This job recreates only Compose project doxstation. It does not stop other projects."
        '''
      }
    }

    stage('Deploy edge') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        sh '''
          set -euo pipefail
          cp -f .env.example .env
          export PUBLIC_APP_URL="${PUBLIC_APP_URL:-https://play.doxstation.com}"
          export WEB_HOST_PORT="${WEB_HOST_PORT:-3010}"
          export API_HOST_PORT="${API_HOST_PORT:-8010}"
          export EDGE_COMPOSE_PROJECT_NAME=doxstation
          export IMAGE_TAG=latest
          echo "Deploying edge project doxstation. Play upstream ${WEB_HOST_PORT}/${API_HOST_PORT}."
          bash scripts/deploy.sh
        '''
      }
    }

    stage('Check') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        sh '''
          set -euo pipefail
          docker compose -p doxstation -f docker-compose.yml ps
          if docker compose -p doxstation -f docker-compose.yml exec -T edge wget -S -O /dev/null --header='Host: play.doxstation.com' http://127.0.0.1/ 2>&1 | grep -q HTTP; then
            echo "edge_ok"
          else
            echo "ERROR: edge did not answer on :80"
            docker compose -p doxstation -f docker-compose.yml logs --tail=80
            exit 1
          fi
        '''
      }
    }
  }

  post {
    success {
      echo "doxstation edge build #${env.BUILD_NUMBER} succeeded"
      echo "HTTP:  http://play.doxstation.com"
      echo "HTTPS: ${params.PUBLIC_APP_URL}"
    }
    failure {
      echo "doxstation edge build #${env.BUILD_NUMBER} failed. The other Compose projects were not stopped."
      sh 'docker compose -p doxstation -f docker-compose.yml logs --tail=80 || true'
    }
  }
}
