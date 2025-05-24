FROM node:22-slim

WORKDIR /app

COPY . .

RUN npm install

ENTRYPOINT ["npm", "start"]

EXPOSE 3000