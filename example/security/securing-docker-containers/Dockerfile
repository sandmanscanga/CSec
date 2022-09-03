## TIP 2: Use a multi-stage build + distroless base image
### First Stage ###
# Base Image
FROM node:12 as build
WORKDIR /usr/src/app

# Install Dependencies
COPY package.json .
RUN npm install

# Copy in the Application
COPY . .

### Second Stage ###
FROM gcr.io/distroless/nodejs:12

# Copy App + Dependencies from build stage
COPY --from=build /usr/src/app /usr/src/app
WORKDIR /usr/src/app

# Change the user to non-root
USER 1000

## TIP 1: Don't run the container as the root user
# Change the user to non-root
# We could use the named user "node" or the numerical id
#USER node

# Run the Server
CMD ["server.js"]
