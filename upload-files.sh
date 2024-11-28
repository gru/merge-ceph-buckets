#!/bin/bash

source ./config.sh

if [ $# -lt 2 ]; then
    echo "Использование: $0 <директория> <бакет>"
    exit 1
fi

DIRECTORY="$1"
BUCKET="$2"

if [ ! -d "$DIRECTORY" ]; then
    echo "Ошибка: $DIRECTORY не является директорией"
    exit 1
fi

find "$DIRECTORY" -type f | while read file; do
    FILENAME=$(basename "$file")
    DATE=$(date -R)
    CONTENT_TYPE=$(file --mime-type -b "$file")
    
    STRING_TO_SIGN="PUT\n\n${CONTENT_TYPE}\n${DATE}\n/${BUCKET}/${FILENAME}"
    SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)
	
    curl -X PUT \
        -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
        -H "Date: ${DATE}" \
        -H "Content-Type: ${CONTENT_TYPE}" \
        --data-binary "@${file}" \
        "http://${HOST}/${BUCKET}/${FILENAME}"
		
	echo "Файл ${FILENAME} загружен"
done