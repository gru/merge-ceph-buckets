#!/bin/bash

source ./config.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 <bucket>"
    exit 1
fi

BUCKET="$1"
DATE=$(date -R)
OUTPUT_FILE="${BUCKET}-contents.txt"

STRING_TO_SIGN="GET\n\n\n${DATE}\n/${BUCKET}"
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

curl -s -X GET \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    "http://${HOST}/${BUCKET}" | \
    grep -o '<Key>[^<]*</Key>' | \
    sed 's/<Key>//;s/<\/Key>//' > ${OUTPUT_FILE}

echo "Список файлов сохранен в ${OUTPUT_FILE}"