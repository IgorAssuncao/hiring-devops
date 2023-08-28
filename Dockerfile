FROM node:18.14.1 as builder

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit dev

FROM node:18.14.1-slim as runner

WORKDIR /app
USER node

COPY --chown=node:node --from=builder /app/node_modules/ ./node_modules/
COPY --from=builder /tini /usr/bin/tini
COPY --chown=node:node ./ ./

ENTRYPOINT [ "tini", "--", "npm" ]
CMD [ "start" ]
