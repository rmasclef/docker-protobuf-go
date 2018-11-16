FROM golang:alpine as builder

# add credentials on build
ARG SSH_PRIVATE_KEY

RUN mkdir /root/.ssh && \
    echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa

RUN apk update && \
    apk add openssh-client

# make sure tf1 github domain is accepted
RUN touch /root/.ssh/known_hosts && \
    ssh-keyscan github.dedale.tf1.fr >> /root/.ssh/known_hosts

# Install dependencies
RUN apk update && \
    apk add git && \
    go get -u -v github.com/golang/protobuf/protoc-gen-go && \
    go get -u -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway && \
    go get -u -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger && \
    go get -u -v github.com/qneyrat/go-grpc-endpoints/protoc-gen-goendpoints && \
    go get -u -v github.com/swaggo/swag/cmd/swag && \
    go get -u -v github.com/rakyll/statik && \
    go get -u -v go.etf1.tf1.fr/etf1-platform/go-grpc-server/protoc-gen-gogrpcserver && \
    #install binaries
    go install -v github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger && \
    go install -v github.com/qneyrat/go-grpc-endpoints/protoc-gen-goendpoints && \
    go install -v go.etf1.tf1.fr/etf1-platform/go-grpc-server/protoc-gen-gogrpcserver

FROM alpine
# install protobuf
RUN apk add protobuf
# copy generated binaries in /usr/bin
COPY --from=builder /go/bin /usr/bin
