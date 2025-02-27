FROM node:23.9.0-alpine3.21
RUN addgroup -S nonroot && adduser -S nonroot -G nonroot
USER nonroot
WORKDIR /app
COPY ./public /app/public
COPY ./src /app/src
COPY package.json .
RUN npm install
EXPOSE 3000
RUN npm run build
CMD ["npm", "start"]
