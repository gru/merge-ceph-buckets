#!/bin/bash

source ./config.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 <file> <bucket>"
    exit 1
fi

FILE="$1"
BUCKET="$2"
DATE=$(date -R)
CONTENT_TYPE=$(file --mime-type -b "$FILE")
FILENAME=$(basename "$FILE")

STRING_TO_SIGN="PUT\n\n${CONTENT_TYPE}\n${DATE}\n/${BUCKET}/${FILENAME}"
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

curl -X PUT \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    -H "Content-Type: ${CONTENT_TYPE}" \
    --data-binary "@${FILE}" \
    "http://${HOST}/${BUCKET}/${FILENAME}"