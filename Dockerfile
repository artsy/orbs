FROM circleci/circleci-cli:alpine
COPY ./scripts /tmp/orb-scripts
RUN apk add --no-cache bash git curl jq
