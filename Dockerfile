FROM node:23-alpine3.20
WORKDIR /app
COPY ./public /app/public
COPY ./src /app/src
COPY package.json .
RUN npm install
EXPOSE 3000
RUN npm run build
CMD ["npm", "start"]
