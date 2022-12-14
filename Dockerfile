FROM openjdk:11.0.12-jdk-slim

LABEL org.opencontainers.image.source https://github.com/sslcom/ci-images

ENV USERNAME=""
ENV PASSWORD=""
ENV CREDENTIAL_ID=""
ENV TOTP_SECRET=""
ENV CODE_SIGN_TOOL_PATH=/codesign
ENV ENVIRONMENT_NAME=PROD

# Install Packages
RUN apt update && apt dist-upgrade -y && apt install -y unzip vim wget curl

# Add CodeSignTool
ADD --chown=root:root CodeSignTool-v1.2.5.zip /tmp/CodeSignTool-v1.2.5.zip

RUN unzip "/tmp/CodeSignTool-v1.2.5.zip" -d "/tmp" && mv "/tmp/CodeSignTool-v1.2.5" "/codesign" && \
    chmod +x "/codesign/CodeSignTool.sh" && ln -s "/codesign/CodeSignTool.sh" "/usr/bin/codesign"

COPY ./codesign-tool/ /codesign
COPY ./entrypoint.sh /entrypoint.sh
COPY ./examples /codesign/examples

RUN chmod +x /entrypoint.sh
RUN mkdir -p /codesign/output

WORKDIR /codesign

ENTRYPOINT ["/entrypoint.sh"]
