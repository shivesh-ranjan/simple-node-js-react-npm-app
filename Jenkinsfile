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
			//   agent {
			//docker {
			//    image 'aquasec/trivy'
			//    reuseNode true
			//}
			//   }
		    steps {
			script {
			    sh 'pwd'
			    sh 'touch $HOME/result.json'
			    sh 'docker run -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/result.json:$HOME/result.json aquasec/trivy repo --format cyclonedx --scanners vuln --output $HOME/result.json https://github.com/shivesh-ranjan/simple-node-js-react-npm-app.git'
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
	    archiveArtifacts artifacts: '/var/lib/jenkins/result.json', onlyIfSuccessful: true
	}
    }
}
