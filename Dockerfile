FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

COPY full-stack-blogging-app/target/twitter-app-0.0.3.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]
