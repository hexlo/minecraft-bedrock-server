#!/bin/sh
curl -v -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
https://www.minecraft.net/en-us/download/server/bedrock/ 2>&1 \
| grep -o 'https://www.minecraft.net/bedrockdedicatedserver/bin-linux/bedrock-server-[^"]*' \
| sed 's#.*/bedrock-server-##' | sed 's/.zip//'
