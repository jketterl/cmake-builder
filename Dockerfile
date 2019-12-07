ARG DIST
FROM debian:$DIST

RUN apt-get update && \
    apt-get install -y cmake build-essential debsigs file wget gnupg && \
    rm -rf /var/lib/apt/lists/*

ADD docker/build-package.sh /

CMD [ "/build-package.sh" ]