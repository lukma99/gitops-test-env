FROM node:18.15.0-alpine

# Set the current image tag on build time in order to display it on the NodeJS webb app
ARG DOCKER_TAG
ENV APP_VERSION=$DOCKER_TAG
RUN echo "Bulding Docker image version: $APP_VERSION"

WORKDIR /usr/src/app

# Install app dependencies
COPY package*.json ./
RUN npm install --only=production
# Copy app
COPY server.js ./

# Run app on port 3000
EXPOSE 3000
CMD [ "npm", "start" ]