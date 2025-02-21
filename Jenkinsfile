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
			    sh 'trivy fs --exit-code 1 --severity CRITICAL --format template --template "@/usr/local/share/trivy/templates/html.tpl" -o trivy-sca-CRITICAL-results.html .'
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
		    sh 'trivy image --exit-code 1 --severity CRITICAL --format template --template "@/usr/local/share/trivy/templates/html.tpl" -o trivy-image-CRITICAL-results.html derekshaw/simple-node-js:$GIT_COMMIT'
	        }
	    }
	}
	stage('DAST') {
	    steps {
		script {
		    sh 'docker run --name mynodeapp -d -p 3000:3000 derekshaw/simple-node-js:$GIT_COMMIT'
		    sh 'docker pull zaproxy/zap-stable'
		    sh 'docker run -u root --name zap -v $(pwd)/zap:/zap/wrk:rw --network="host" zaproxy/zap-stable zap-full-scan.py -t http://localhost:3000 -r zap-scan-report.html'
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
		docker stop mynodeapp
		docker rm mynodeapp
		docker stop zap
		docker rm zap
	    '''
	    sh 'docker rmi derekshaw/simple-node-js:$GIT_COMMIT'
            //sh 'trivy convert --format template --template /usr/local/share/trivy/templates/html.tpl --output trivy-image-CRITICAL-results.html trivy-image-CRITICAL-results.json'
            //sh 'trivy convert --format template --template /usr/local/share/trivy/templates/html.tpl --output trivy-sca-CRITICAL-results.html trivy-sca-CRITICAL-results.json'
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-image-CRITICAL-results.html", reportName: "Trivy Image Critical Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-sca-CRITICAL-results.html", reportName: "Trivy SCA Critical Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./zap", reportFiles: "zap-scan-report.html", reportName: "ZAP DAST Scan Report", reportTitles: "", useWrapperFileDirectly: true])
	    //archiveArtifacts artifacts: 'zap/zap-scan-report.html', onlyIfSuccessful: false
	}
    }
}
