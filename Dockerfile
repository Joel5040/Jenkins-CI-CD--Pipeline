FROM eclipse-temurin:11-jre

WORKDIR /app

# Copy the compiled JAR from the Maven build
COPY target/my-app-*.jar /app/my-app.jar

# Run the application
ENTRYPOINT ["java", "-jar", "/app/my-app.jar"]
