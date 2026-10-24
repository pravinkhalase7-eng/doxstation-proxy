pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timeout(time: 20, unit: 'MINUTES')
  }

  parameters {
    booleanParam(
      name: 'SKIP_DEPLOY',
      defaultValue: false,
      description: 'Build only — skip starting the edge container'
    )
  }

  environment {
    COMPOSE_PROJECT_NAME = 'doxstation'
    EDGE_IMAGE           = "doxstation-edge:${env.BUILD_NUMBER}"
    EDGE_IMAGE_LATEST    = 'doxstation-edge:latest'
    PLAY_WEB_PORT        = '3010'
    PLAY_API_PORT        = '8010'
    NGINX_HTTP_PORT      = '80'
    NGINX_HTTPS_PORT     = '443'
    NGINX_SERVER_NAME    = 'play.doxstation.com'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh '''
          test -f Jenkinsfile
          test -f docker-compose.yml
          test -f nginx/Dockerfile
          test -f nginx/default.conf
          test -f nginx/play.inc
          test -f nginx/35-play-upstreams.sh
          test -f nginx/40-https.sh
          test -f scripts/install_edge.sh
        '''
      }
    }

    stage('Docker Build') {
      steps {
        sh '''
          set -e
          docker build -t ${EDGE_IMAGE} -t ${EDGE_IMAGE_LATEST} ./nginx
          docker images | grep doxstation-edge | head
        '''
      }
    }

    stage('Deploy') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        sh '''
          set -e
          echo "=== Free :80/:443 from leftover aicoder-nginx if present ==="
          docker rm -f aicoder-nginx-1 aicoder-edge-1 2>/dev/null || true

          echo "=== Start doxstation-edge (does not touch aicoder) ==="
          docker compose -p doxstation -f docker-compose.yml up -d --build --remove-orphans
          docker compose -p doxstation -f docker-compose.yml ps
        '''
      }
    }

    stage('TLS') {
      when {
        expression { return !params.SKIP_DEPLOY }
      }
      steps {
        sh '''
          set -e
          export NGINX_SERVER_NAME="play.doxstation.com"
          export PLAY_WEB_PORT="${PLAY_WEB_PORT:-3010}"
          export PLAY_API_PORT="${PLAY_API_PORT:-8010}"
          bash scripts/install_edge.sh
        '''
      }
    }
  }

  post {
    success {
      echo "doxstation-edge ${env.BUILD_NUMBER} ready on :80/:443"
    }
    failure {
      sh 'docker compose -p doxstation -f docker-compose.yml logs --tail=80 || true'
    }
  }
}
