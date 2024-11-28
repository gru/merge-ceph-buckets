#!/bin/bash

source ./config.sh

if [ $# -lt 3 ]; then
    echo "Использование: $0 <имя-файла> <исходный-бакет> <целевой-бакет>"
    exit 1
fi

FILENAME="$1"
SOURCE_BUCKET="$2"
DEST_BUCKET="$3"
DATE=$(date -R)

# Проверяем существование файла в целевом бакете
STRING_TO_SIGN="HEAD\n\n\n${DATE}\n/${DEST_BUCKET}/${FILENAME}"
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

RESPONSE=$(curl -I -s -X HEAD \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    "http://${HOST}/${DEST_BUCKET}/${FILENAME}")

if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "Пропускаем: ${FILENAME} уже существует в целевом бакете"
    exit 0
fi

# Копируем объект
DATE=$(date -R)
STRING_TO_SIGN="PUT\n\n\n${DATE}\nx-amz-copy-source:/${SOURCE_BUCKET}/${FILENAME}\n/${DEST_BUCKET}/${FILENAME}"
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

curl -X PUT \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    -H "x-amz-copy-source: /${SOURCE_BUCKET}/${FILENAME}" \
    "http://${HOST}/${DEST_BUCKET}/${FILENAME}"
