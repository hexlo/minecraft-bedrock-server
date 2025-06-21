FROM ubuntu:focal

ARG VERSION=

ENV LATEST_VERSION=""

ENV SERVER_DIR=/bedrock-server

ENV LD_LIBRARY_PATH=${SERVER_DIR}

ENV VERSION_FILE=${SERVER_DIR}/local-version.txt

RUN apt update && apt install -y curl unzip nano wget

WORKDIR ${SERVER_DIR}

# RUN mkdir -p ${SERVER_DIR}/{defaults,config,worlds,info,resource_packs,scripts}
RUN mkdir -p ${SERVER_DIR}/defaults ${SERVER_DIR}/config ${SERVER_DIR}/worlds ${SERVER_DIR}/info ${SERVER_DIR}/resource_packs ${SERVER_DIR}/scripts

COPY ./.scripts/* ${SERVER_DIR}/scripts/

RUN chmod +x ${SERVER_DIR}/scripts/* \
    && mv ${SERVER_DIR}/scripts/start-server.sh ${SERVER_DIR}/start-server.sh

### Install Script

RUN export DOWNLOADED_VERSION=$(${SERVER_DIR}/scripts/download-latest-version.sh ${SERVER_DIR} ${VERSION}); \
    echo "VERSION=${DOWNLOADED_VERSION}"; \
    echo "${DOWNLOADED_VERSION}" > ${VERSION_FILE};

RUN cp -a ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/defaults/allowlist.json;
RUN cp -a ${SERVER_DIR}/permissions.json ${SERVER_DIR}/defaults/permissions.json;
RUN cp -a ${SERVER_DIR}/server.properties ${SERVER_DIR}/defaults/server.properties;
RUN mv -vn ${SERVER_DIR}/allowlist.json ${SERVER_DIR}/config/allowlist.json;
RUN mv -vn ${SERVER_DIR}/permissions.json ${SERVER_DIR}/config/permissions.json;
RUN mv -vn ${SERVER_DIR}/server.properties ${SERVER_DIR}/config/server.properties;
RUN ln -s ${SERVER_DIR}/config/allowlist.json ${SERVER_DIR}/allowlist.json;
RUN ln -s ${SERVER_DIR}/config/permissions.json ${SERVER_DIR}/permissions.json;
RUN ln -s ${SERVER_DIR}/config/server.properties ${SERVER_DIR}/server.properties;
RUN chmod +x ${SERVER_DIR}/bedrock_server;

EXPOSE 19132/udp

VOLUME ["${SERVER_DIR}/worlds", "${SERVER_DIR}/config", "${SERVER_DIR}/info", "${SERVER_DIR}/resource_packs"]

WORKDIR ${SERVER_DIR}

CMD ["/bin/sh", "-c", "./start-server.sh"]

