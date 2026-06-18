pipeline {

    agent {
        label 'devops-agent'
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
                        sh 'mvn clean package -DskipTests'
                    }
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('maven') {
                    withSonarQubeEnv('sonarqube') {
 pipeline {

    agent {
        label 'devops-agent'
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
                        sh 'mvn clean package -DskipTests'
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
                            mvn clean verify sonar:sonar \
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
                        trivy fs --format table -o trivy-report.txt .
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
    }
}
