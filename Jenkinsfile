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
			    sh '''
				trivy fs --format json -o trivy-sca-results.json .
				sh scripts/trivy-sca.sh
			    '''
			    sh 'scripts/count_severity.sh trivy_sca_severity_count.json'
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
		    sh '''
			trivy image --format json -o trivy-image-results.json derekshaw/simple-node-js:$GIT_COMMIT
			jq -r '.Results[].Vulnerabilities[].Severity' trivy-image-results.json | sort | uniq -c | awk '{print "{\"severity\": \""$2"\", \"count\": "$1"}"}' > trivy_image_severity_count.json
		    '''
		    sh 'scripts/count_severity.sh trivy_image_severity_count.json'
	        }
	    }
	}
	stage('DAST') {
	    steps {
		script {
		    sh '''docker run --name mynodeapp -d -p 3000:3000 derekshaw/simple-node-js:$GIT_COMMIT
		    	  docker pull zaproxy/zap-stable
		    	  echo 'docker run -u root --name zap -v $(pwd)/zap:/zap/wrk:rw --network="host" zaproxy/zap-stable zap-full-scan.py -t http://localhost:3000 -r zap-scan-report.html' > script.sh
		    	  echo 'if [ $? == 1 ] || [ $? == 3 ]' >> script.sh
	 		  echo 'then' >> script.sh
      			  echo '  exit 1' >> script.sh
	   		  echo 'else' >> script.sh
			  echo '  exit 0' >> script.sh
     			  echo 'fi' >> script.sh
	 		  sh script.sh
			'''
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
            sh 'trivy convert --format template --template "@/usr/local/share/trivy/templates/html.tpl" --output trivy-sca-results.html trivy-sca-results.json'
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-sca-results.html", reportName: "Trivy SCA Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    sh 'rm trivy-sca-results.html'
	    sh 'rm trivy-sca-results.json'
            sh 'trivy convert --format template --template "@/usr/local/share/trivy/templates/html.tpl" --output trivy-image-results.html trivy-image-results.json'
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-image-results.html", reportName: "Trivy Image Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    sh 'rm trivy-image-results.html'
	    sh 'rm trivy-image-results.json'
	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./zap", reportFiles: "zap-scan-report.html", reportName: "ZAP DAST Scan Report", reportTitles: "", useWrapperFileDirectly: true])
	    sh 'rm zap/zap-scan-report.html'
	    sh '''
		docker stop mynodeapp
		docker rm mynodeapp
	    '''
	    sh '''
		docker stop zap
		docker rm zap
	    '''
	    sh 'docker rmi derekshaw/simple-node-js:$GIT_COMMIT'
	    //archiveArtifacts artifacts: 'zap/zap-scan-report.html', onlyIfSuccessful: false
	}
    }
}
