[![Buy me a coffee](https://github.com/hexlo/terraria-server-docker/raw/gh-pages/assets/yellow-button-256w.png)](https://www.buymeacoffee.com/hexlo)  

```                
 __  __     ______     __  __     __         ______    
/\ \_\ \   /\  ___\   /\_\_\_\   /\ \       /\  __ \   
\ \  __ \  \ \  __\   \/_/\_\/_  \ \ \____  \ \ \/\ \  
 \ \_\ \_\  \ \_____\   /\_\/\_\  \ \_____\  \ \_____\ 
  \/_/\/_/   \/_____/   \/_/\/_/   \/_____/   \/_____/ 
                                                       
                   
```
# Minecraft Bedrock Server
Docker Hub mirror: [https://hub.docker.com/r/hexlo/minecraft-bedrock-server](https://hub.docker.com/r/hexlo/minecraft-bedrock-server)

## Initial Setup

You can easily import your world and config files. Here is an example docker-compose.yml:
Change the path of the volumes approprietly.
```
services:

  minecraft-server:
    # Github ghcr mirror: ghcr.io/iceoid/minecraft-bedrock-server:latest
    image: hexlo/minecraft-bedrock-server:latest
    container_name: minecraft-server
    stdin_open: true # docker run -i
    tty: true        # docker run -t
    restart: unless-stopped
    ports:
      - 19132:19132/udp
    volumes:
      - ./path_to/config:/bedrock-server/config
      - ./path_to/worlds:/bedrock-server/worlds
```

If you want multiple servers running concurrently, you can have different ports for each one, and port forward accordingly. ie.:
```
    ports:
      - 20000:19132/udp
```
This server would run on port 20000.

In your config folder, have the following 3 files _(don't include them if you would like new default ones)_:
- *server.properties* _(edit as you wish)_
- *allowlist.json* _(if whitelist=true is set in the server.properties, you need to add players in this file as follow. The xuid will be generated automatically)_
```
[
     {
         "ignoresPlayerLimit": false,
         "name": "Player1"
     },
     {
         "ignoresPlayerLimit": false,
         "name": "Player2",
         "xuid": "12346764585"
     }
]
```
- *permissions.json* _(give players permissions. You need the xuid of the players. Either look at the allowlist.json file after adding players or use an online [xuid grabber](https://www.cxkes.me/xbox/xuid))_
```
[
     {
         "permission": "operator",
         "xuid": "12346764585"
     }
]
```
The structure of the worlds folder is as follow:
```
bedrock-server
|__worlds
     |__level
          |__db
             level.dat
             level.dat_old
             levelname.txt
```

## Usage

### Start the server
The server will start with the container

### Stop the server without stopping the container
`docker attach minecraft-server`\
`stop`

### You can use server side commands. 

First, attach to the container with
`docker attach minecraft-server`

Here is a list of [useful commands](https://minecraftbedrock-archive.fandom.com/wiki/Commands/List_of_Commands)
Don't include the forward slash before the commands ie: instead of `/say Hello!` use `say Hello!`

To dettach without stopping the container
`Ctrl+p + Ctrl+q`
