#!/bin/bash

docker build -t distroless .
docker run -i -d -p 8080:8080 distroless:latest
