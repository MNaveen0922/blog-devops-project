pipeline {

    agent {
        label 'devops-agent'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        IMAGE_NAME = "naveen0922/twitter-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                container('maven') {
                    dir('full-stack-blogging-app') {
                        sh '''
                        mvn clean package -DskipTests
                        '''
                    }
                }
            }
        }

        stage('Download Dependencies') {
            steps {
                container('maven') {
                    dir('full-stack-blogging-app') {
                        sh '''
                        mvn dependency:resolve
                        '''
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('maven') {
                    withSonarQubeEnv('sonarqube') {
                        dir('full-stack-blogging-app') {
                            sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=blog-app \
                            -Dsonar.projectName=blog-app
                            '''
                        }
                    }
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                container('trivy') {
                    dir('full-stack-blogging-app') {
                        sh '''
                        trivy fs \
                        --scanners vuln \
                        --skip-dirs target \
                        --format table \
                        -o trivy-report.txt . || true
                        '''
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                container('kaniko') {
                    sh '''
                    /kaniko/executor \
                    --context=${WORKSPACE} \
                    --dockerfile=${WORKSPACE}/Dockerfile \
                    --destination=${IMAGE_NAME}:${IMAGE_TAG} \
                    --destination=${IMAGE_NAME}:latest \
                    --cleanup
                    '''
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                container('trivy') {
                    sh '''
                    sleep 20

                    trivy image \
                    --severity HIGH,CRITICAL \
                    --exit-code 0 \
                    --format table \
                    -o image-scan-report.txt \
                    docker.io/${IMAGE_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Update Deployment Manifest') {
            steps {

                sh '''
                sed -i "s|image:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/deployment.yaml

                echo "Updated deployment.yaml:"
                grep image k8s/deployment.yaml
                '''
            }
        }

        stage('Push Deployment Manifest to GitHub') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_PASS'
                    )
                ]) {

                    sh '''
                    git config --global user.email "mnaveen0922@gmail.com"
                    git config --global user.name "MNaveen0922"

                    git add k8s/deployment.yaml

                    git commit -m "Updated image to ${IMAGE_TAG}" || true

                    git push https://${GIT_USER}:${GIT_PASS}@github.com/MNaveen0922/blog-devops-project.git HEAD:main
                    '''
                }
            }
        }

    }

    post {

        always {

            archiveArtifacts artifacts: '**/*.txt', allowEmptyArchive: true

        }

        success {

            echo '======================================'
            echo 'Pipeline completed successfully'
            echo "Docker Image: ${IMAGE_NAME}:${IMAGE_TAG}"
            echo '======================================'

        }

        failure {

            echo '======================================'
            echo 'Pipeline failed'
            echo '======================================'

        }
    }
}
