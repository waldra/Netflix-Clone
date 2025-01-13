pipeline {
    agent any
    
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        APP_NAME = "netflix"
        RELEASE = "1.0.0"
        DOCKER_USER = "waldara"
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/waldra/Netflix-Clone.git'
            }
        }
        
        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv('sonarqube-server') {
                    sh ''' ${SCANNER_HOME}/bin/sonar-scanner -Dsonar.projectKey=Netflic-Clone \
                            -Dsonar.projectName=Netflix-Clone '''
                }
            }
        }
        
         stage('Quality Gate Check') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true, credentialsId: 'sonarqube-token'
                }
            }
        }
        stage('Trivy Fs Scan') {
            steps {
                sh "trivy fs . > trivy-fs-report.txt"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }
        
        stage('OWASP dependency-check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit ', odcInstallation: 'dependency-check' 
                dependencyCheckPublisher pattern:'**/dependency-check-report.xml'
            }
        }
        
        stage('Docker Image Build & Push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: '', toolName: 'docker') {
                        sh 'docker image build --build-arg TMDB_V3_API_KEY= -t ${APP_NAME} .'
                        sh 'docker image tag ${APP_NAME} ${IMAGE_NAME}:${IMAGE_TAG}'
                        sh 'docker image push ${IMAGE_NAME}:${IMAGE_TAG}'
                    }
                }
            }
        }
        
        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} > trivy-image-report.txt'
            }
        }
        
        stage('Update Netflix-CD Repo') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'git-cred', gitToolName: 'Default')]) {
                    sh '''
                       git clone https://github.com/waldra/Netflix-CD.git
                       cd Netflix-CD/kube-manifests
                       repo_dir=$(pwd)
                       sed -i 's|image: waldara/netflix.*|image: waldara/netflix:'${IMAGE_TAG}'|' ${repo_dir}/deployment.yml
                       '''
                    
                    sh '''
                       cd Netflix-CD/kube-manifests
                       
                       git config user.name "Jenkins"
                       git config user.email "Jenkins@gmail.com"
                       
                       git add deployment.yml
                       git commit -m "Update image tag to ${IMAGE_TAG}"
                       git push origin main
                       '''
                }
            }
}

    }
    
    post {
        always {
            script {
                sh 'docker rmi ${IMAGE_NAME}:${IMAGE_TAG}'
            }
            emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'ahmedwaldra@gmail.com',  
            attachmentsPattern: 'trivy-image-report.txt,trivy-fs-report.txt'
        }
    }
}
