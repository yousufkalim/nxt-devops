# syntax=docker/dockerfile:1

FROM node:18-alpine

# Setting up the working directory
WORKDIR /app

# Copying only necessary files (ignoring unnecessary files like deploy.sh, deployment.yml, service.yml)
COPY package.json yarn.lock ./
COPY src ./src

# Installing the dependencies
RUN yarn install --production

# Exposing the port where our app meant to run
EXPOSE 3000

# Defining the environment
ENV NODE_ENV=production

# Using a non-root user for better security (I'm not using non-root user as the boilerplate I'm using in this project require root privileges)
# USER node

# Specifying the command to run on startup
CMD ["node", "src/index.js"]
