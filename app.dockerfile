# Stage 1: Build the Spring Boot JAR
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy only the app folder with pom.xml and src
COPY LibraryProject2/pom.xml .
COPY LibraryProject2/src ./src

RUN mvn -DskipTests clean package

# Stage 2: Run the JAR
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
