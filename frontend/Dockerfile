### STAGE 1: Build ###
FROM node:lts-alpine AS build
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
RUN npm run build

### STAGE 2: Run ###
FROM nginx:alpine

COPY .docker /
COPY --from=build /app/dist/spa /var/www/html/pwndoc
RUN echo "Install dependencies and fix permissions." && set -xe \
    && apk --no-cache add openssl \
    && chown -R nginx:nginx /var/www/html \
    && chmod 0755 /usr/local/bin/* \
    && rm -f /etc/nginx/default.conf \
    && rm -f /usr/local/src/* \
    && rm -rf /var/cache/apk \
    && rm -f /tmp/*

EXPOSE 443
VOLUME /certs
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
