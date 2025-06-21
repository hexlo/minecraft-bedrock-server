#!/bin/bash
BASE_DOWNLOAD_URL=https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-
SCRAPE_URL=https://minecraft.wiki/w/Bedrock_Dedicated_Server

# First Argument is the output location. Defaults to current directory
[[ -z ${1} ]] && dest=. || dest=${1%/}

# Second Argument is a fixed version to download (optional). If omitted, it'll scrape the webpage to find the latest version.
if [[ -z ${2} ]]
then
    LATEST_VERSION=$(curl -v -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
    ${SCRAPE_URL} 2>&1 \
    | grep -o '<li><b><a href="/w/Bedrock_Dedicated_Server_[^"]*' \
    | tail -1 \
    | sed 's#.*/Bedrock_Dedicated_Server_##')
else
    LATEST_VERSION=${2}
fi;

curl -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
    ${BASE_DOWNLOAD_URL}${LATEST_VERSION}.zip --output ${dest}/bedrock-server.zip \
    && unzip -qq -o ${dest}/bedrock-server.zip -d ${dest} \
    && rm ${dest}/bedrock-server.zip

echo ${LATEST_VERSION}