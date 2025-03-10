# grpc-proto
Project model grpc proto
* Cấu hình credential cho github và telegram
```angular2html
Cấu hình tại Dashboard>Manage Jenkins>Credentials>System
Global>credentials (unrestricted)
trong jenkins
```
* Cấu hình file Jenkinsfile

```groovy 
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
```

* Cấu hình file ~/.m2/settings/xml
```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                      http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <activeProfiles>
    <activeProfile>github</activeProfile>
  </activeProfiles>

  <profiles>
    <profile>
      <id>github</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>https://repo1.maven.org/maven2</url>
        </repository>
        <repository>
          <id>github</id>
          <url>https://maven.pkg.github.com/OWNER/REPOSITORY</url>
<!--            bật cho phép triển khai các file build snapshot-->
          <snapshots>
            <enabled>true</enabled> 
          </snapshots>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <servers>
    <server>
      <id>github</id>
      <username>USERNAME</username>
      <password>TOKEN</password>
    </server>
  </servers>
</settings>
```
* Thêm cấu hình vào pom.xml
  * Tạo file .github/workflows/maven-packages.yaml với nội dung:
```xml
<distributionManagement>
   <repository>
     <id>github</id>
     <name>GitHub OWNER Apache Maven Packages</name>
     <url>https://maven.pkg.github.com/OWNER/REPOSITORY</url>
   </repository>
</distributionManagement>
```
* Thực hiện build và deploy maven packages
```shell
mvn deploy
```
or 
```shell
mvn deploy -DrepositoryId=github \
                    -Durl=https://maven.pkg.github.com/${GITHUB_USERNAME}/${GITHUB_REPOSITORY} \
                    -Dusername=${GITHUB_USER} \
                    -Dpassword=${GITHUB_TOKEN}
```

## Sử dụng github Action để thao tác CI thay cho Jenkins
```yaml
name: Build and Publish Maven Package

on:
  push:
    branches:
      - main  # Thay đổi nhánh nếu cần (ví dụ: master)

jobs:
  build-and-publish:
    runs-on: ubuntu-latest

    steps:
      # Checkout mã nguồn từ repository
      - name: Checkout repository
        uses: actions/checkout@v4

      # Cài đặt JDK (Java Development Kit)
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      # Build dự án Maven và đẩy artifact lên GitHub Packages
      - name: Build with Maven and Publish to GitHub Packages
        env:
          GITHUB_TOKEN: ${{ secrets.GIT_TOKEN }}  # Sử dụng PAT từ secrets
        run: |
          mvn -B package --file pom.xml
          mvn -B deploy --file pom.xml -DskipTests
```