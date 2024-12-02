#!/bin/bash

source ./config.sh

if [ $# -lt 2 ]; then
    echo "Использование: $0 <количество-файлов> <бакет>"
    exit 1
fi

COUNT="$1"
BUCKET="$2"
TMP_DIR="tmp_files"

# Создаем временную директорию
mkdir -p ${TMP_DIR}

# Генерируем и загружаем файлы
for i in $(seq 1 ${COUNT}); do
    FILENAME="${i}.txt"
    FILEPATH="${TMP_DIR}/${FILENAME}"
    
    # Создаем файл с содержимым
    echo "${i}" > ${FILEPATH}
    
    # Загружаем файл
    DATE=$(date -R)
    CONTENT_TYPE="text/plain"
    
    STRING_TO_SIGN="PUT\n\n${CONTENT_TYPE}\n${DATE}\n/${BUCKET}/${FILENAME}"
    SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)
    
    RESPONSE=$(curl -s -X PUT \
        -T "${FILEPATH}" \
        -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
        -H "Date: ${DATE}" \
        -H "Content-Type: ${CONTENT_TYPE}" \
        -w "%{http_code}" \
        -o /dev/null \
        "http://${HOST}/${BUCKET}/${FILENAME}")
    
    if [ "$RESPONSE" == "200" ]; then
        echo "Файл ${FILENAME} успешно загружен"
    else
        echo "Ошибка при загрузке файла ${FILENAME}: $RESPONSE"
    fi
done

# Очищаем временные файлы
rm -rf ${TMP_DIR}

echo "Загрузка завершена. Всего загружено файлов: ${COUNT}"