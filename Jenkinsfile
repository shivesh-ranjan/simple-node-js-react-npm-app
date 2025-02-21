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
		//       stage('SAST') {
		//           steps {
		//	script {
		//    	    def scannerHome = tool 'sonarqube'
		//    	    withSonarQubeEnv() {
		//		sh "${scannerHome}/bin/sonar-scanner"
		//    	    }
		//	}
		//   	    }
		//}
		stage('SCA and Secrets Scan') {
		    steps {
			script {
			    sh 'touch result.json'
			    sh 'docker run --name trivySCA -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/workspace/simple-node-js/result.json:$HOME/result.json aquasec/trivy repo --exit-code 1 --severity CRITICAL --format cyclonedx --scanners vuln --output $HOME/result.json https://github.com/shivesh-ranjan/simple-node-js-react-npm-app.git'
			}
		    }
		}
	    }
	}
	stage('Building Image') {
	    steps {
		sh 'docker build -t derekshaw/simple-node-js:$GIT_COMMIT .'
	    }
	}
	stage('Scanning Image') {
	    steps {
		script {
		    sh 'touch imgResult.json'
		    sh 'docker run --name trivyIMG -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/jenkins/workspace/simple-node-js/imgResult.json:$HOME/result.json aquasec/trivy image --exit-code 1 --severity CRITICAL --format cyclonedx --scanners vuln --output $HOME/result.json derekshaw/simple-node-js:$GIT_COMMIT'
	        }
	    }
	}
	stage('DAST') {
	    steps {
		script {
		    sh 'docker run --name mynodeapp -d -p 3000:3000 derekshaw/simple-node-js:$GIT_COMMIT'
		    sh 'docker pull zaproxy/zap-stable'
		    sh 'touch zap-scan-report.html'
		    sh 'docker run --name zap -v $(pwd):/zap/wrk:rw -v /var/lib/jenkins/workspace/simple-node-js/zap-scan-report.html:/zap/wrk/zap-scan-report.html zaproxy/zap-stable zap-full-scan.py -t http://localhost:3000 -r zap-scan-report.html'
		}
	    }
	}
	stage('Pushing Image to Registry') {
	    steps {
		script {
		    withDockerRegistry(credentialsId: 'docker-hub-credentials', toolName: 'docker') {
			sh 'docker push derekshaw/simple-node-js:$GIT_COMMIT'
		    }
		}
	    }
	}
    }
    post {
	always {
	    sh '''
		docker stop trivySCA
		docker rm trivySCA
		docker stop trivyIMG
		docker rm trivyIMG
		docker stop mynodeapp
		docker rm mynodeapp
		docker stop zap
		docker rm zap
	    '''
	    sh 'docker rmi derekshaw/simple-node-js:$GIT_COMMIT'
	    archiveArtifacts artifacts: 'result.json', onlyIfSuccessful: true
	    archiveArtifacts artifacts: 'imgResult.json', onlyIfSuccessful: true
	    archiveArtifacts artifacts: 'zap-scan-report.html', onlyIfSuccessful: true
	}
    }
}
