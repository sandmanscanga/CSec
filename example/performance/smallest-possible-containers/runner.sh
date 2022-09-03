#!/bin/bash

# docker-clean -a

docker build -t node-naive node
docker run -i -d -p 8080:8080 node-naive:latest

docker build -t go-naive go
docker run -i -d -p 8081:8081 go-naive:latest
