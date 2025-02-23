pipeline {
    agent any

    tools {
        jdk 'jdk11'  // Đảm bảo rằng JDK đã được cấu hình trong Global Tool Configuration
        maven 'Maven3'   // Cấu hình Maven nếu cần

    }

    environment {
        GITHUB_USER = credentials('github_credential')
        GITHUB_TOKEN = credentials('github_credential')
        GITHUB_USERNAME = 'hatrongvu13'
        GITHUB_REPOSITORY = 'grpc-proto'
        TELEGRAM_TOKEN =  credentials('telegram_credential')
        CHAT_ID = '-4088493477'
        BUILD_URL = "${env.BUILD_URL}"
        BUILD_NUMBER = "${env.BUILD_NUMBER}"
        JOB_NAME = "${env.JOB_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/hatrongvu13/grpc-proto.git'  // Thay thế với repo của bạn
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    // Chạy Maven để build dự án
                    sh 'mvn clean install'
                }
            }
        }

        // stage('Test') {
        //     steps {
        //         script {
        //             // Chạy các bài kiểm tra (nếu có)
        //             sh 'mvn test'
        //         }
        //     }
        // }
        stage('Publish jar to Github Packages') {
            steps {
                sh '''
                mvn deploy \
                    -DrepositoryId=github \
                    -Durl=https://maven.pkg.github.com/${GITHUB_USERNAME}/${GITHUB_REPOSITORY} \
                    -Dusername=${GITHUB_USER} \
                    -Dpassword=${GITHUB_TOKEN}
                '''
            }
        }
    }

    post {
        success {
            echo 'Build thành công!'
            // sh '''
            // curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
            //     -d "chat_id=${CHAT_ID}" \
            //     -d "text=✅ Jenkins Build Successful! 🎉"
            // '''

            sh '''
            MESSAGE="✅ *Jenkins Build Successful!* 🎉%0A"
            MESSAGE="${MESSAGE} 🏗 *Job*: ${JOB_NAME}%0A"
            MESSAGE="${MESSAGE} 🔢 *Build Number*: ${BUILD_NUMBER}%0A"
            MESSAGE="${MESSAGE} 🔗 *URL*: [View Build](${BUILD_URL})%0A"
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                -d "parse_mode=Markdown" \
                -d "text=${MESSAGE}"
            '''
        }
        failure {
            echo 'Build thất bại!'
            // sh '''
            // curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
            //     -d "chat_id=${CHAT_ID}" \
            //     -d "text=❌ Jenkins Build Failed! 🚨"
            // '''

            sh '''
            MESSAGE="❌ *Jenkins Build Failed!* 🚨%0A"
            MESSAGE="${MESSAGE}🏗 *Job*: ${JOB_NAME}%0A"
            MESSAGE="${MESSAGE}🔢 *Build Number*: ${BUILD_NUMBER}%0A"
            MESSAGE="${MESSAGE}🔗 *URL*: [View Build](${BUILD_URL})%0A"
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                -d "parse_mode=Markdown" \
                -d "text=${MESSAGE}"
            '''
        }
    }
}