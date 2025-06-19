#!/bin/bash

# Set fallback values if not already set
VERSION=${VERSION:-latest}
SERVER_DIR=${SERVER_DIR:-/bedrock-server}
VERSION_FILE="${SERVER_DIR}/local-version.txt"

if [ -f "$VERSION_FILE" ]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
  echo "Current version: $CURRENT_VERSION"
else
  CURRENT_VERSION="0.0.0.0"
  echo "No local version found. Assuming $CURRENT_VERSION"
fi

if [ "$VERSION" = "latest" ]; then
  echo "Resolving latest version..."
  VERSION=$(sh /scripts/get-latest-version.sh)
  echo "Latest version: $VERSION"
else
  echo "Using fixed version $VERSION"
fi

if [ "$(printf '%s\n' "$VERSION" "$CURRENT_VERSION" | sort -V | tail -n1)" != "$CURRENT_VERSION" ]; then
  echo "A newer version ($VERSION) is available."
  echo "$VERSION" > "$VERSION_FILE"
  echo "Downloading version $VERSION..."
  sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"
elif [ "$VERSION" != "$CURRENT_VERSION" ]; then
  echo "A different version ($VERSION) is specified, but it is not the latest."
  echo "$VERSION" > "$VERSION_FILE"
  echo "Downloading version $VERSION..."
  sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"
else
  echo "Already up to date ($CURRENT_VERSION)."
fi

cp -a /${SERVER_DIR}/local-version.txt /${SERVER_DIR}/info/version.txt

### Copy the default files to a default directory
RUN cp -a ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/defaults/allowlist.json \
    && cp -a ${SERVER_DIR}/permissions.json ${SERVER_DIR}/defaults/permissions.json \
    && cp -a ${SERVER_DIR}/server.properties ${SERVER_DIR}/defaults/server.properties 

### Overwrite the files in the config directory with the defaults if there are no files present
RUN mv -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/config/allowlist.json \
    && mv -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/config/permissions.json \
    && mv -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/config/server.properties

### Create a symbolic link to the config files in the server directory
RUN ln -s ${SERVER_DIR}/config/allowlist.json ${SERVER_DIR}/allowlist.json \
    && ln -s ${SERVER_DIR}/config/permissions.json ${SERVER_DIR}/permissions.json \
    && ln -s ${SERVER_DIR}/config/server.properties ${SERVER_DIR}/server.properties \
    && chmod +x ${SERVER_DIR}/bedrock_server

# Check if config files exists
permissions=/${SERVER_DIR}/config/permissions.json
if [ -f "${permissions}" ]; then
    echo "${permissions} exists."
else 
    echo "${permissions} does not exist."
    cp -a /${SERVER_DIR}/defaults/permissions.json ${permissions}
    chmod 777 ${permissions}
fi

allowlist=/${SERVER_DIR}/config/allowlist.json
if [ -f "${allowlist}" ]; then
    echo "${allowlist} exists."
else 
    echo "${allowlist} does not exist."
    cp -a /${SERVER_DIR}/defaults/allowlist.json ${allowlist}
    chmod 777 ${allowlist}
fi

serverProperties=/${SERVER_DIR}/config/server.properties
if [ -f "${serverProperties}" ]; then
    echo "${serverProperties} exists."
else 
    echo "${serverProperties} does not exist."
    cp -a /${SERVER_DIR}/defaults/server.properties ${serverProperties}
    chmod 777 ${serverProperties}
fi

# Run Server
./bedrock_server
