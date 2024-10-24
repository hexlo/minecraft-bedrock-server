#!/bin/bash
# First Argument is the output location. Defaults to current directory
[[ -z ${1} ]] && dest=. || dest=${1%/}

URL=https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-

LATEST_VERSION=$(curl -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
    https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 \
    | grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-[^"]*' \
    | sed 's#.*/bedrock-server-##' \
    | sed 's/\.zip//')
curl -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
    ${URL}${LATEST_VERSION}.zip --output ${dest}/bedrock-server.zip \
    && unzip -qq -o ${dest}/bedrock-server.zip -d ${dest} \
    && rm ${dest}/bedrock-server.zip
echo ${LATEST_VERSION}
