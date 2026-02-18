FROM node:20.14
WORKDIR /usr/src/app

# Leverage Docker cache for faster builds
COPY package*.json .
RUN npm install --quiet

# Copy the rest app files
COPY . .
EXPOSE 8000
CMD ["node","./src/app.js"]