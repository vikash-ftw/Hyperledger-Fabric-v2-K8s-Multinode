# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

ARG GO_VER=1.22
ARG ALPINE_VER=3.21

FROM golang:${GO_VER}-alpine${ALPINE_VER}

WORKDIR /src/chaincode-external
COPY . .

RUN go get -d -v ./...
RUN go install -v ./...

CMD ["chaincode-external"]