FROM eclipse-temurin:11.0.18_10-jdk-jammy

LABEL org.opencontainers.image.source=https://github.com/SSLcom/ci-images

ENV USERNAME=""
ENV PASSWORD=""
ENV CREDENTIAL_ID=""
ENV TOTP_SECRET=""
ENV CODE_SIGN_TOOL_PATH=/codesign
ENV ENVIRONMENT_NAME=PROD

# Install Packages
RUN apt update && apt install -y unzip vim wget curl

# Add CodeSignTool
ADD --chown=root:root "https://github.com/SSLcom/CodeSignTool/releases/download/v1.3.0/CodeSignTool-v1.3.0.zip" "/tmp/CodeSignTool-v1.3.0.zip"

RUN mkdir -p "/codesign" && unzip "/tmp/CodeSignTool-v1.3.0.zip" -d "/codesign" && \
    chmod +x "/codesign/CodeSignTool.sh" && ln -s "/codesign/CodeSignTool.sh" "/usr/bin/codesign"

COPY ./codesign-tool/ /codesign
COPY ./entrypoint.sh /entrypoint.sh
COPY ./examples /codesign/examples

RUN chmod +x /entrypoint.sh
RUN mkdir -p /codesign/output

WORKDIR /codesign

ENTRYPOINT ["/entrypoint.sh"]
