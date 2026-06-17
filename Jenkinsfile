pipeline {
    agent any

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {

        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                dir('full-stack-blogging-app') {
                    sh 'mvn clean package'
                }
            }
        }

    }
}
