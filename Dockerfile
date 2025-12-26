# --- STAGE 1: BUILD ---
# Use a Maven image to build the app
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Copy the project files
COPY pom.xml .
COPY src ./src

# Build the application (skipping tests to speed it up)
RUN mvn clean package -DskipTests

# --- STAGE 2: RUN ---
# Use a lighter JDK image to run the app
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app

# Copy the built JAR file from the previous stage
# Note: We rename it to 'app.jar' so the command is simple
COPY --from=build /app/target/*.jar app.jar

# Expose the port Render uses (usually 8080)
EXPOSE 8080

# The command to start the app
ENTRYPOINT ["java", "-jar", "app.jar"]