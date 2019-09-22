FROM alpine:3.10  AS base
RUN apk --no-cache add nodejs nodejs-npm tini  --virtual native-deps \
  g++ gcc libgcc libstdc++ linux-headers autoconf automake make nasm python git && \
  npm install --quiet node-gyp -g

WORKDIR /parse
ENTRYPOINT ["/sbin/tini", "--"]
COPY package.json .


FROM base AS dependencies
RUN npm set progress=false && npm config set depth 0 
RUN npm install --only=production && npm audit fix



#FROM dependencies AS test
#COPY . .
#RUN  npm run lint && npm run setup && npm run test


FROM node:12.10.0-alpine  AS release
COPY --from=dependencies /parse/node_modules  ./node_modules
RUN mkdir -p logs && chown -R node: logs
COPY . .
EXPOSE 1337
USER node
CMD [ "npm", "start" ]
