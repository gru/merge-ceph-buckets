#!/bin/bash

source ./config.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 <bucket-name>"
    exit 1
fi

BUCKET="$1"
DATE=$(date -R)

STRING_TO_SIGN="PUT\n\n\n${DATE}\n/${BUCKET}"
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

echo "Создаем бакет ${BUCKET}"

curl -X PUT \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    "http://${HOST}/${BUCKET}"
	
echo "Бакет ${BUCKET} успешно создан"