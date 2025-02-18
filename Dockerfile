FROM openjdk:17
LABEL authors="hatrongvu"
ENV SERVER_PORT=8080
WORKDIR /opt/service
COPY /target/*.jar /opt/service/app.jar
EXPOSE $SERVER_PORT
RUN chgrp -R 0 ./ && chmod -R g=u ./
CMD ["java", "-jar", "app.jar"]