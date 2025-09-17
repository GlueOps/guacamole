# Stage 1: The Downloader Stage
# We use a lightweight image with download tools to get the official binary release.
# This approach downloads the specific SSO extension bundle.

# Set the version for Guacamole. RenovateBot can use the release tags from the
# guacamole-client GitHub repository to suggest updates for this ARG.
# renovate: datasource=github-releases depName=apache/guacamole-client
ARG GUAC_VERSION=1.6.0@sha256:f344085e618bb05e22b964b0208dbd06d3468275bac70206f93805245e067b40

FROM debian:bullseye-slim@sha256:6d3c63184632046054ae709964befc943ecffa140adc697ca955a10002a79c08 AS downloader

# Install required tools for downloading and extracting
RUN apt-get update && apt-get install -y wget tar && rm -rf /var/lib/apt/lists/*

# Forward the version argument into this stage
ARG GUAC_VERSION

# Set the working directory
WORKDIR /tmp

# --- Debugging Step ---
RUN echo "Downloading Guacamole SSO binary version: ${GUAC_VERSION}"

# Download the official Guacamole SSO binary distribution and its checksum from the Apache archives ref: https://guacamole.apache.org/releases/
RUN wget "https://archive.apache.org/dist/guacamole/${GUAC_VERSION}/binary/guacamole-auth-sso-${GUAC_VERSION}.tar.gz" \
    && wget "https://archive.apache.org/dist/guacamole/${GUAC_VERSION}/binary/guacamole-auth-sso-${GUAC_VERSION}.tar.gz.sha256"
# Verify the checksum of the downloaded binary
RUN sha256sum -c "guacamole-auth-sso-${GUAC_VERSION}.tar.gz.sha256"
# Extract the archive to get access to the OpenID extension
RUN tar -xzf "guacamole-auth-sso-${GUAC_VERSION}.tar.gz"

# ---

# Stage 2: The Final Image
# We use the official Guacamole image as our base.
FROM guacamole/guacamole:${GUAC_VERSION}

# Forward the version argument into the final stage
ARG GUAC_VERSION

# Set the GUACAMOLE_HOME to the new directory so Guacamole can find its files.
ENV GUACAMOLE_HOME=/home/guacamole/glueops

# Create the extensions directory inside our new GUACAMOLE_HOME.
RUN mkdir -p $GUACAMOLE_HOME/extensions


# Copy only the required OpenID SSO JAR from the downloader stage to the new extensions directory.
# The path reflects the structure of the guacamole-auth-sso archive.
COPY --from=downloader "/tmp/guacamole-auth-sso-${GUAC_VERSION}/openid/guacamole-auth-sso-openid-${GUAC_VERSION}.jar" $GUACAMOLE_HOME/extensions/


