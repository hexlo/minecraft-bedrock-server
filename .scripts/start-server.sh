#!/bin/bash

# Copy version to shared volume
#cat /bedrock-server/local-version.txt > /bedrock-server/info/version.txt
cp -a /bedrock-server/local-version.txt /bedrock-server/info/version.txt

# Check if config files exists
permissions=/bedrock-server/config/permissions.json
if [ -f "${permissions}" ]; then
    echo "${permissions} exists."
else 
    echo "${permissions} does not exist."
    cp -a /bedrock-server/defaults/permissions.json ${permissions}
    chmod 777 ${permissions}
fi

allowlist=/bedrock-server/config/allowlist.json
if [ -f "${allowlist}" ]; then
    echo "${allowlist} exists."
else 
    echo "${allowlist} does not exist."
    cp -a /bedrock-server/defaults/allowlist.json ${allowlist}
    chmod 777 ${allowlist}
fi

serverProperties=/bedrock-server/config/server.properties
if [ -f "${serverProperties}" ]; then
    echo "${serverProperties} exists."
else 
    echo "${serverProperties} does not exist."
    cp -a /bedrock-server/defaults/server.properties ${serverProperties}
    chmod 777 ${serverProperties}
fi

# Run Server
./bedrock_server
