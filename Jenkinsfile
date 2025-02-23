// pipeline {
//     agent any
//
//     tools {
//         jdk 'jdk11'  // Đảm bảo rằng JDK đã được cấu hình trong Global Tool Configuration
//         maven 'Maven3'   // Cấu hình Maven nếu cần
//     }
//
//     environment {
//         GITHUB_USER = credentials('github_credential')
//         GITHUB_TOKEN = credentials('github_credential')
//         GITHUB_USERNAME = 'hatrongvu13'
//         GITHUB_REPOSITORY = 'grpc-proto.git'
//         TELEGRAM_TOKEN = credentials('telegram_credential')
//         CHAT_ID = '-4088493477'
//     }
//
//     stages {
//         stage('Checkout') {
//             steps {
//                 script {
//                     git branch: 'main', url: 'https://github.com/hatrongvu13/grpc-proto.git'  // Thay thế với repo của bạn
//                 }
//             }
//         }
//
//         stage('Build') {
//             steps {
//                 script {
//                     // Chạy Maven để build dự án
//                     sh 'mvn clean install'
//                 }
//             }
//         }
//
//         // stage('Test') {
//         //     steps {
//         //         script {
//         //             // Chạy các bài kiểm tra (nếu có)
//         //             sh 'mvn test'
//         //         }
//         //     }
//         // }
//         stage('Publish jar to Github Packages') {
//             steps {
//                 sh '''
//                 mvn deploy \
//                     -DrepositoryId=github \
//                     -Durl=https://maven.pkg.github.com/${GITHUB_USERNAME}/${GITHUB_REPOSITORY} \
//                     -Dusername=${GITHUB_USER} \
//                     -Dpassword=${GITHUB_TOKEN}
//                 '''
//             }
//         }
//     }
//
//     post {
//         success {
//             echo 'Build thành công!'
//         }
//         failure {
//             echo 'Build thất bại!'
//         }
//     }
// }

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
        TELEGRAM_TOKEN =  credentials('telegram_credential') //'1977594188:AAH6f9mjUjl1HVqj5LEeoJq9dyxq7WfvsmE'
        CHAT_ID = '-4088493477'
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
            sh '''
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                -d "text=✅ Jenkins Build Successful! 🎉"
            '''
        }
        failure {
            echo 'Build thất bại!'
            sh '''
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
                -d "chat_id=${CHAT_ID}" \
                -d "text=❌ Jenkins Build Failed! 🚨"
            '''
        }
    }
}