#!/bin/sh
curl -v -L --silent -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.63 Safari/537.36" \
https://minecraft.wiki/w/Bedrock_Dedicated_Server 2>&1 \
| grep -o '<li><b><a href="/w/Bedrock_Dedicated_Server_[^"]*' \
| tail -1 \
| sed 's#.*/Bedrock_Dedicated_Server_##'
