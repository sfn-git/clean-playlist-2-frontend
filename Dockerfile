FROM node:24-slim

WORKDIR /app

RUN npm install -g http-server

COPY package.json .
COPY package-lock.json .

RUN npm install --force
COPY . .

EXPOSE 8080

CMD [ "bash", "start.sh" ]