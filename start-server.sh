#!/bin/bash

# Copy version to shared volume
cat /bedrock-server/local-version.txt > /bedrock-server/info/version.txt

# Run Server
cd /bedrock-server
./bedrock_server
