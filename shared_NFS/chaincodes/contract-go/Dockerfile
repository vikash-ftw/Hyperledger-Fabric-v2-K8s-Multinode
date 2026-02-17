# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

ARG GO_VER=1.22
ARG ALPINE_VER=3.21

FROM golang:${GO_VER}-alpine${ALPINE_VER}

# Install git (required by go mod tidy to fetch dependencies)
RUN apk add --no-cache git

WORKDIR /src/chaincode-external
COPY . .

# Generate the missing go.sum and download dependencies inside the container
RUN go mod tidy

# Force the name to 'chaincode-external'
RUN go build -o /usr/local/bin/chaincode-external .

CMD ["chaincode-external"]