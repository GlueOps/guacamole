# guacamole

This directory contains a custom Docker build for [Apache Guacamole](https://guacamole.apache.org/) with the OpenID SSO extension pre-installed.

## Overview

- **Base Image:** Uses the official `guacamole/guacamole` Docker image.
- **Extension:** Downloads and installs the OpenID SSO extension (`guacamole-auth-sso-openid`) for the specified Guacamole version.
- **Build Automation:** Includes a GitHub Actions workflow to build and publish the image to GHCR.

## Dockerfile

The [Dockerfile](guacamole/Dockerfile) performs a two-stage build:

1. **Downloader Stage:**  
   Downloads and extracts the OpenID SSO extension for the specified Guacamole version.
2. **Final Stage:**  
   - Uses the official Guacamole image as the base.
   - Copies the OpenID SSO JAR into the correct extensions directory.
   - Sets `GUACAMOLE_HOME` to `/home/guacamole/glueops/`.

You can adjust the Guacamole version by changing the `GUAC_VERSION` build argument.

## Building the Image

To build the Docker image locally:

```sh
docker build -t guacamole-custom:latest .
```

## GitHub Actions

The [container_image.yml](guacamole/.github/workflows/container_image.yml) workflow:

- Builds the Docker image on push.
- Tags and pushes the image to GitHub Container Registry (GHCR).

## Usage

After building or pulling the image, run it as you would the standard Guacamole container, but with the OpenID SSO extension available in `/home/guacamole/glueops/extensions/`.

## References

- [Apache Guacamole Documentation](https://guacamole.apache.org/doc/gug/)
- [Guacamole SSO Extensions](https://guacamole.apache.org/doc/gug/openid-auth.html)