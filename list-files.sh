#!/bin/bash

source ./config.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 <bucket>"
    exit 1
fi

BUCKET="$1"
OUTPUT_FILE="${BUCKET}-contents.txt"
TEMP_FILE="${BUCKET}-temp.xml"
MARKER=""

# Очищаем выходной файл
> ${OUTPUT_FILE}

while true; do
    DATE=$(date -R)
    
    # Формируем URL с маркером
    if [ -z "$MARKER" ]; then
        URL="http://${HOST}/${BUCKET}"
    else
        URL="http://${HOST}/${BUCKET}?marker=${MARKER}"
    fi
    
    # Формируем подпись
    STRING_TO_SIGN="GET\n\n\n${DATE}\n/${BUCKET}"
    
    SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

    # Получаем очередную порцию списка
    curl -s -X GET \
        -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
        -H "Date: ${DATE}" \
        "${URL}" > ${TEMP_FILE}
    
    # Извлекаем имена файлов
    grep -o '<Key>[^<]*</Key>' ${TEMP_FILE} | \
        sed 's/<Key>//;s/<\/Key>//' >> ${OUTPUT_FILE}
    
    # Извлекаем чистое значение маркера без дополнительных параметров
    MARKER=$(grep -o '<NextMarker>[^<]*</NextMarker>' ${TEMP_FILE} | \
        sed 's/<NextMarker>//;s/<\/NextMarker>//' | \
        sed 's/\[.*\]$//' | \
        sed 's/marker=//')
    
    echo "Получено файлов: $(wc -l < ${OUTPUT_FILE})"
    
    # Если маркера нет, значит достигли конца списка
    [ -z "$MARKER" ] && break
done

rm -f ${TEMP_FILE}

TOTAL_FILES=$(wc -l < ${OUTPUT_FILE})
echo "Получение списка завершено. Всего файлов: ${TOTAL_FILES}"
echo "Список файлов сохранен в ${OUTPUT_FILE}"