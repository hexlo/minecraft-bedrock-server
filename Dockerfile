FROM ubuntu:focal

ARG VER=latest

ENV VERSION=$VER

ENV LATEST_VERSION=""

ENV SERVER_DIR=/bedrock-server

ENV LD_LIBRARY_PATH=${SERVER_DIR}

ENV VERSION_FILE=${SERVER_DIR}/local-version.txt

RUN apt update && apt install -y curl unzip nano

WORKDIR ${SERVER_DIR}

RUN mkdir -p ${SERVER_DIR}/defaults ${SERVER_DIR}/config ${SERVER_DIR}/worlds ${SERVER_DIR}/info ${SERVER_DIR}/resource_packs /scripts

COPY ./.scripts/* /scripts/

RUN chmod +x /scripts/* \
    && mv /scripts/start-server.sh ${SERVER_DIR}/start-server.sh

RUN \
  if [ -f "$VERSION_FILE" ]; then \
    CURRENT_VERSION=$(cat "$VERSION_FILE"); \
    echo "Current version: $CURRENT_VERSION"; \
  else \
    CURRENT_VERSION="0.0.0.0"; \
    echo "Current version: $CURRENT_VERSION"; \
  fi \
  && if [ "$VERSION" = "latest" ]; then \
    echo "Using latest version..."; \
    VERSION=$(sh /scripts/get-latest-version.sh); \
    echo "Latest version: $VERSION"; \
  else \
    echo "Using fixed version $VERSION"; \
  fi \
  && if [ ""$(printf '%s\n' "$VERSION" "$CURRENT_VERSION" | sort -V | tail -n1)"" != "$CURRENT_VERSION" ]; then \
    echo "A newer version ($VERSION) is available."; \
    echo "$VERSION" > "$VERSION_FILE"; \
    echo "Start downloading version: $VERSION"; \
    sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"; \
   elif [  "$VERSION" != "$CURRENT_VERSION" ]; then \
    echo "A different version ($VERSION) is specified, but it is not the latest."; \
    echo "$VERSION" > "$VERSION_FILE"; \
    echo "Start downloading version: $VERSION"; \
    sh /scripts/download-latest-version.sh "$SERVER_DIR" "$VERSION"; \
   else \
    echo "Already up to date ($CURRENT_VERSION)."; \
  fi

### Copy the default files to a default directory
RUN cp -a ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/defaults/allowlist.json \
    && cp -a ${SERVER_DIR}/permissions.json ${SERVER_DIR}/defaults/permissions.json \
    && cp -a ${SERVER_DIR}/server.properties ${SERVER_DIR}/defaults/server.properties 

### Overwrite the files in the config directory with the defaults if there are no files present
RUN mv -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/config/allowlist.json \
    && mv -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/config/permissions.json \
    && mv -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/config/server.properties

### Create a symbolic link to the config files in the server directory
RUN ln -s ${SERVER_DIR}/config/allowlist.json ${SERVER_DIR}/allowlist.json \
    && ln -s ${SERVER_DIR}/config/permissions.json ${SERVER_DIR}/permissions.json \
    && ln -s ${SERVER_DIR}/config/server.properties ${SERVER_DIR}/server.properties \
    && chmod +x ${SERVER_DIR}/bedrock_server

EXPOSE 19132/udp

VOLUME ["${SERVER_DIR}/worlds", "${SERVER_DIR}/config", "${SERVER_DIR}/info", "${SERVER_DIR}/resource_packs"]

WORKDIR ${SERVER_DIR}

CMD ["/bin/sh", "-c", "./start-server.sh"]
