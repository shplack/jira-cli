# Usage:
#   $ docker build -t jira-cli:latest .
#   $ docker run --rm -it -v ~/.netrc:/root/.netrc -v ~/.config/.jira:/root/.config/.jira jira-cli

FROM golang:1.24-alpine3.21 AS builder

ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /app

COPY .git .git
COPY api api
COPY cmd cmd
COPY internal internal
COPY pkg pkg
COPY .deepsource.toml .deepsource.toml
COPY go.mod go.mod
COPY go.sum go.sum
COPY Makefile Makefile

RUN set -eux; \
    env ; \
    ls -la ; \
    apk add -U --no-cache make git ; \
    make deps install

FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /go/bin/jira /bin/jira

ENTRYPOINT ["/bin/jira"]
