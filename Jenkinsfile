pipeline {
    agent any
    tools {
	nodejs"nodejs"
    }
    stages {
        stage('Build') { 
            steps {
                sh 'npm install' 
            }
        }
	stage('Testing and Code Analysis'){
	    parallel {
	        stage('Test') { 
        	    steps {
                	sh './jenkins/scripts/test.sh' 
            	    }
        	}
	        stage('SAST') {
	            steps {
			script {
		    	    def scannerHome = tool 'sonarqube'
		    	    withSonarQubeEnv() {
				sh "${scannerHome}/bin/sonar-scanner"
		    	    }
			}
	    	    }
		}
		stage('SCA and Secrets Scan') {
		    steps {
			script {
			    sh 'touch result.json'
			    sh 'docker run --name trivy -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/workspace/simple-node-js/result.json:$HOME/result.json aquasec/trivy repo --exit-code 1 --severity CRITICAL --format cyclonedx --scanners vuln --output $HOME/result.json https://github.com/shivesh-ranjan/simple-node-js-react-npm-app.git'
			    sh 'docker stop trivy'
			    sh 'docker rm trivy'
			}
		    }
		}
	    }
	}
	stage('Building Image') {
	    steps {
		sh 'docker build -t derekshaw/simple-node-js:1.0 .'
	    }
	}
	stage('Scanning Image') {
	    steps {
		script {
		    sh 'touch imgResult.json'
		    sh 'docker run --name trivy -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/workspace/simple-node-js/imgResult.json:$HOME/result.json aquasec/trivy image --exit-code 1 --severity CRITICAL --format cyclonedx --scanners vuln --output $HOME/result.json derekshaw/simple-node-js:1.0'
		    sh 'docker stop trivy'
		    sh 'docker rm trivy'
	        }
	    }
	}
    }
    post {
	always {
	    archiveArtifacts artifacts: 'result.json', onlyIfSuccessful: true
	    archiveArtifacts artifacts: 'imgResult.json', onlyIfSuccessful: true
	}
    }
}
