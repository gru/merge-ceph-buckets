#!/bin/bash

source ./config.sh

if [ $# -lt 3 ]; then
    echo "Использование: $0 <имя-файла> <бакет> <локальный-путь>"
    exit 1
fi

FILENAME="$1"
BUCKET="$2"
LOCAL_PATH="$3"

DATE=$(date -R)

STRING_TO_SIGN="GET\n\n\n${DATE}\n/${BUCKET}/${FILENAME}"

SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

# Скачиваем файл
RESPONSE=$(curl -s -o "${LOCAL_PATH}" \
    -w "%{http_code}" \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    "http://${HOST}/${BUCKET}/${FILENAME}")

if [ "$RESPONSE" == "200" ]; then
    echo "Файл ${FILENAME} успешно скачан в ${LOCAL_PATH}"
    exit 0
else
    echo "Ошибка при скачивании файла ${FILENAME}: $RESPONSE"
    rm -f "${LOCAL_PATH}"
    exit 1
fi