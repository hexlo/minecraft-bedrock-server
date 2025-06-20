#!/bin/sh
# First Argument is the output location. Defaults to current directory
if [ -z "$1" ]; then
  dest="."
else
  dest="${1%/}"
fi

# Second argument: version (required)
version="$2"

if [ -z "$version" ]; then
  echo "Error: No version specified."
  echo "Usage: $0 [destination] version"
  exit 1
fi

URL="https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-${version}.zip"

curl -L --silent -H "User-Agent: Mozilla/5.0" "$URL" --output "${dest}/bedrock-server.zip"

if [ $? -eq 0 ]; then
  echo "Downloaded version, starting extraction..."
  unzip -qq -o "${dest}/bedrock-server.zip" -d "${dest}" && \
  rm "${dest}/bedrock-server.zip"
  echo "Downloaded version $version to ${dest}"
else
  echo "Failed to download or extract server version $version"
  exit 1
fi
