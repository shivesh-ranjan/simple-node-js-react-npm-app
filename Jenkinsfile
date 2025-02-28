node {
    def agentLabel = ''
    
    if (env.ENV == 'DEV') {
        agentLabel = 'dev-agent'
    } else if (env.ENV == 'PROD') {
        agentLabel = 'prod-agent'
    } else {
        error "Unsupported environment: ${env.ENV}"
    }

    stage('Setup') {
        echo "Running on ${agentLabel} for ${env.ENV} environment"
    }

    stage('Build') {
        echo 'Building the project...'
    }

    stage('Test') {
        echo 'Running tests...'
    }

    stage('Deploy') {
        echo 'Deploying the project...'
    }

}

