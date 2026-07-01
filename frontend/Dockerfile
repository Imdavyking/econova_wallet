# syntax=docker/dockerfile:1

ARG NODE_VERSION=22.8.0
ARG NODE_ENV=development

FROM node:${NODE_VERSION}-alpine

ENV NODE_ENV=${NODE_ENV}


WORKDIR /usr/src/app

# Install python3, build-base, and gcc to build native dependencies
RUN apk add --update --no-cache python3 build-base gcc && ln -sf /usr/bin/python3 /usr/bin/python

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.yarn to speed up subsequent builds.
# Leverage a bind mounts to package.json and yarn.lock to avoid having to copy them into
# into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=yarn.lock,target=yarn.lock \
    --mount=type=cache,target=/root/.yarn \
    yarn install --frozen-lockfile


# Copy the rest of the source files into the image.
COPY . .

# Expose the port that the application listens on.
EXPOSE 3000

# Run the application.
CMD yarn dev --host



