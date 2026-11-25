FROM eclipse-temurin:25-jre

WORKDIR /app
COPY app.jar /app/app.jar

# 视频上传目录
RUN mkdir -p /app/uploads/video

EXPOSE 9091

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
