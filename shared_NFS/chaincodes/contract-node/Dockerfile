FROM node:18-alpine

WORKDIR /usr/src/external-chaincode

COPY package*.json .
RUN npm install --quiet

COPY . .

EXPOSE 7053

CMD ["npm", "start"]