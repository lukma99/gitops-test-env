FROM node:18.15.0-alpine

ARG DOCKER_TAG
ENV APP_VERSION=$DOCKER_TAG
RUN echo "Bulding Docker image version: $APP_VERSION"

WORKDIR /usr/src/app
# Install app dependencies
COPY package*.json ./
RUN npm install --only=production
# Copy app
COPY server.js ./

EXPOSE 3000
CMD [ "npm", "start" ]