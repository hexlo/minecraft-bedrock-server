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

### Install Script
RUN if [ "${VERSION}" = "latest" ]; then \
        echo "using latest version." \
    &&  export LATEST_VERSION=$(/scripts/download-latest-version.sh ${SERVER_DIR}) \
    &&  export VERSION=${LATEST_VERSION}; fi \
    && echo "VERSION=${VERSION}" \
    && echo "${VERSION}" > ${VERSION_FILE} \
    #
    && cp -a ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/defaults/allowlist.json \
    && cp -a ${SERVER_DIR}/permissions.json ${SERVER_DIR}/defaults/permissions.json \
    && cp -a ${SERVER_DIR}/server.properties ${SERVER_DIR}/defaults/server.properties \
    #
    && mv -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/config/allowlist.json \
    && mv -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/config/permissions.json \
    && mv -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/config/server.properties \
    #
    && ln -s ${SERVER_DIR}/config/allowlist.json ${SERVER_DIR}/allowlist.json \
    && ln -s ${SERVER_DIR}/config/permissions.json ${SERVER_DIR}/permissions.json \
    && ln -s ${SERVER_DIR}/config/server.properties ${SERVER_DIR}/server.properties \
    && chmod +x ${SERVER_DIR}/bedrock_server

EXPOSE 19132/udp

VOLUME ["${SERVER_DIR}/worlds", "${SERVER_DIR}/config", "${SERVER_DIR}/info", "${SERVER_DIR}/resource_packs"]

WORKDIR ${SERVER_DIR}

CMD ["/bin/sh", "-c", "./start-server.sh"]

