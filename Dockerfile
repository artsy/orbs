FROM alpine:latest
COPY ./scripts /tmp/orb-scripts
RUN apk add --no-cache bash git curl jq
