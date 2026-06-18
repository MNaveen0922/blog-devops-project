pipeline {

    agent {
        label 'devops-agent'
    }

    options {
        timestamps()
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
    }

    post {
        always {
            archiveArtifacts artifacts: 'full-stack-blogging-app/trivy-report.txt', allowEmptyArchive: true
        }

        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}
