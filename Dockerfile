FROM golang:alpine as builder
# Install dependencies
RUN apk update && \
    apk add protobuf && \
    apk add git && \
    go get -u -v github.com/golang/protobuf/protoc-gen-go && \
    go get -u -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway

FROM alpine
# copy generated binaries in /usr/bin
COPY --from=builder /go/bin /usr/bin
# copy protoc binary
COPY --from=builder /usr/bin/protoc /usr/bin
# copy protoc lib dependancies
COPY --from=builder /usr/lib/libproto* "/usr/lib/libstdc++*" /usr/lib/libgcc* /usr/lib/
