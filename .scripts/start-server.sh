#!/bin/bash

# Set fallback values if not already set
VERSION=${VERSION:-latest}
SERVER_DIR=${SERVER_DIR:-/bedrock-server}
PACKED_VERSION_FILE="${SERVER_DIR}/local-version.txt"
VERSION_FILE="${SERVER_DIR}/info/version.txt"

if [ -f "$PACKED_VERSION_FILE" ]; then
  PACKED_VERSION=$(cat "$PACKED_VERSION_FILE")
  echo "Packed version: $PACKED_VERSION"
else
  PACKED_VERSION="0.0.0.0"
  echo "No local version found. Assuming $PACKED_VERSION"
fi

if [ -f "$VERSION_FILE" ]; then
  CURRENT_WORLD_VERSION=$(cat "$VERSION_FILE")
  echo "Current world version: $CURRENT_WORLD_VERSION"
else
  CURRENT_WORLD_VERSION="0.0.0.0"
  echo "No local version found. Assuming current world version $CURRENT_WORLD_VERSION"
fi

if [ "$VERSION" = "latest" ]; then
  echo "Resolving latest version..."
  VERSION=$(sh /scripts/get-latest-version.sh)
  echo "Latest version: $VERSION"
else
  echo "Using fixed version $VERSION"
fi

if [ "$(printf '%s\n' "$VERSION" "$PACKED_VERSION" | sort -V | tail -n1)" != "$PACKED_VERSION" ]; then
  echo "A newer version ($VERSION) is available."
  echo "Downloading version $VERSION..."
  sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"
  echo "$VERSION" > "$PACKED_VERSION_FILE"
elif [ "$VERSION" != "$PACKED_VERSION" ]; then
  echo "A different version ($VERSION) is specified, but it is not the latest."
  echo "Downloading version $VERSION..."
  sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"
  echo "$VERSION" > "$PACKED_VERSION_FILE"
else
  echo "Already up to date ($PACKED_VERSION_FILE)."
fi

if [ "$VERSION" != "$CURRENT_WORLD_VERSION" ] && [ "$CURRENT_WORLD_VERSION" != "0.0.0.0" ]; then
  echo "New version installed, back-up original world files..."
  
  # Set datetime in desired format: YYYYMMDD_HHMMSS
  datetime=$(date +"%Y%m%d_%H%M%S")
  src="worlds"
  dest="worlds_backup/$CURRENT_WORLD_VERSION/$datetime"

  # Create the destination directory
  mkdir -p "$dest"

  # Copy the contents
  cp -r "$src/"* "$dest/"

  echo "Copied contents of '$src' to '$dest'"
fi

### Copy the latest version to the user directory
cp -a ${PACKED_VERSION_FILE} ${SERVER_DIR}/info/version.txt

### Copy the default files to a default directory (if not already present)
cp -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/defaults/allowlist.json
cp -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/defaults/permissions.json
cp -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/defaults/server.properties 

### Overwrite the files in the config directory with the defaults if there are no files present
mv -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/config/allowlist.json
mv -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/config/permissions.json
mv -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/config/server.properties

### Create a symbolic link to the config files in the server directory
ln -s ${SERVER_DIR}/config/allowlist.json ${SERVER_DIR}/allowlist.json
ln -s ${SERVER_DIR}/config/permissions.json ${SERVER_DIR}/permissions.json
ln -s ${SERVER_DIR}/config/server.properties ${SERVER_DIR}/server.properties

### Make sure the server file is executable
chmod +x ${SERVER_DIR}/bedrock_server

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
