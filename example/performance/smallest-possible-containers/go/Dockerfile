## Stage 1
FROM golang:1.14-alpine as build
WORKDIR /app
COPY . .
RUN go build -o server .

## Stage 2
FROM alpine:3.12
COPY --from=build /app /app
WORKDIR /app
CMD ["/app/server"]
