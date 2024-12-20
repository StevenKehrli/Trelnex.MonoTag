FROM node:23-alpine

RUN <<EOF
    apk update
    apk --no-cache add bash git curl jq && npm install -g semver
EOF

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
