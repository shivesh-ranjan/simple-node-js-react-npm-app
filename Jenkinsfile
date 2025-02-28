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
		//stage('SCA and Secrets Scan') {
		//    steps {
		//	script {
		//	    sh '''
		//		trivy fs --exit-code 1 --severity HIGH,CRITICAL --format json -o trivy-sca-results.json .
		//	    '''
		//	    //sh scripts/trivy-sca.sh
		//	    //sh 'scripts/count_severity.sh trivy_sca_severity_count.json'
		//	}
		//    }
		//}
	    }
	}
	stage('Quality Gate') {
	    steps {
		script {
	            def qg = waitForQualityGate()
	            if (qg.status != 'OK') {
       		        input message: 'Quality Gate of SonarQube returned not OK. Do you still want to continue?'
	            }
		}
	    }
	}
	stage('CIS Docker Compliance') {
	    steps {
		script {
		    def result = sh(script: 'scripts/cis-docker.sh', returnStatus: true)
		    sh 'cat conftestResult.txt'
		    if(result!=0) {
			input message: 'Dockerfile is not following the Best practices as listed in the CIS benchmark for Docker. Do you still want to continue?'
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
			trivy image --severity HIGH,CRITICAL --ignore-unfixed --format json -o trivy-image-results.json derekshaw/simple-node-js:$GIT_COMMIT
		    '''
		    sh 'scripts/trivy-image.sh'
            	    sh 'trivy convert --format template --template "@/usr/local/share/trivy/templates/html.tpl" --output trivy-image-results.html trivy-image-results.json'
	    	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-image-results.html", reportName: "Trivy Image Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	            sh 'rm trivy-image-results.html'
	            sh 'rm trivy-image-results.json'
		    sh 'cat trivy_image_severity_count.json'
		    sh 'scripts/count_severity.sh trivy_image_severity_count.json 10 90' // args: $1:- file_path; $2:- allowed_critical_cves; $3:- allowed_high_cves
	        }
	    }
	}
	stage('DAST') {
	    steps {
		script {
		    sh '''docker run --name mynodeapp -d -p 3000:3000 derekshaw/simple-node-js:$GIT_COMMIT
		    	  docker pull zaproxy/zap-stable
			'''
	 	    def result = sh(script: 'scripts/zap-script.sh', returnStatus: true)
	    	    publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./zap", reportFiles: "zap-scan-report.html", reportName: "ZAP DAST Scan Report", reportTitles: "", useWrapperFileDirectly: true])
		    if(result != 0) {
			currentBuild.result = 'UNSTABLE'
		    }
		}
	    }
	}
	post {
	    always {
		sh '''
		    docker stop mynodeapp
		    docker rm mynodeapp
		'''
		sh '''
		    docker exec zap rm /zap/wrk/zap-scan-report.html
		    docker stop zap
		    docker rm zap
		'''
	    }
	}
	stage('User Input'){
	    when {
		expression { currentBuild.result == 'UNSTABLE' }
	    }
	    steps {
	        input message: 'ZAP test found 1 or more HIGH Risk/s. Do you want to continue?'
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
	    //       sh 'trivy convert --format template --template "@/usr/local/share/trivy/templates/html.tpl" --output trivy-sca-results.html trivy-sca-results.json'
	    //publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-sca-results.html", reportName: "Trivy SCA Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    //sh 'rm trivy-sca-results.html'
	    //sh 'rm trivy-sca-results.json'
	    //       sh 'trivy convert --format template --template "@/usr/local/share/trivy/templates/html.tpl" --output trivy-image-results.html trivy-image-results.json'
	    //publishHTML([allowMissing: true, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "./", reportFiles: "trivy-image-results.html", reportName: "Trivy Image Vul Report", reportTitles: "", useWrapperFileDirectly: true])
	    //sh 'rm trivy-image-results.html'
	    //sh 'rm trivy-image-results.json'
	    sh 'docker rmi derekshaw/simple-node-js:$GIT_COMMIT'
		//   sh '''
		//docker stop mynodeapp
		//docker rm mynodeapp
		//   '''
	    //archiveArtifacts artifacts: 'zap/zap-scan-report.html', onlyIfSuccessful: false
	}
    }
}
