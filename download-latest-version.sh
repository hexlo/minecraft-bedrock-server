#!/bin/sh
VERSION=latest
echo $VERSION
if [ "$VERSION" = "latest" ]; then
    LATEST_VERSION=$(curl -v -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 | grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | sed 's#.*/bedrock-server-##' | sed 's/.zip//')
    export VERSION=$LATEST_VERSION
fi
echo "downloading version ${VERSION}"
curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VERSION}.zip --output bedrock-server.zip && unzip bedrock-server.zip -d bedrock-server && rm bedrock-server.zip
