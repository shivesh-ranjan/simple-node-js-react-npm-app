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
		    agent {
			docker {
			    image 'aquasec/trivy'
			    reuseNode true
			}
		    }
		    steps {
			script {
			     sh 'trivy fs --format cyclonedx --scanners vuln --output result.json .'
			}
		    }
		}
	    }
	}
	//stage('Building Image') {
	//    steps {
	//
	//    }
	//}
    }
    post {
	always {
	    archiveArtifacts artifacts: 'result.json', onlyIfSuccessful: true
	}
    }
}
