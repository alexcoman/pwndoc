FROM node:10.15.2-alpine
ENV NODE_ENV=production

COPY .docker /
RUN echo "Install build dependencies." && set -xe \
    && apk --no-cache add --virtual builds-deps build-base python openssl \
    && chmod 0755 /usr/local/bin/* \
    && rm -f /usr/local/src/* \
    && rm -rf /var/cache/apk \
    && rm -f /tmp/*

WORKDIR /home/node/app
COPY package*.json ./
RUN echo "Install dependencies." && set - xe \
    && npm install --production

COPY . ./

EXPOSE 4242
VOLUME /certs

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npm", "start"]