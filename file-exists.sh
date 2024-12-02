#!/bin/bash

# Загружаем конфигурацию
source ./config.sh

if [ $# -lt 2 ]; then
    echo "Использование: $0 <имя-файла> <имя-бакета>"
    exit 1
fi

FILENAME="$1"
BUCKET="$2"

# Получаем текущую дату в RFC2822 формате
DATE=$(date -R)

# Формируем строку для подписи
STRING_TO_SIGN="HEAD\n\n\n${DATE}\n/${BUCKET}/${FILENAME}"

# Создаем подпись
SIGNATURE=$(echo -en ${STRING_TO_SIGN} | openssl sha1 -hmac ${SECRET_KEY} -binary | base64)

# Выполняем HEAD-запрос для проверки существования файла
RESPONSE=$(curl -I -s -X HEAD \
    -H "Authorization: AWS ${ACCESS_KEY}:${SIGNATURE}" \
    -H "Date: ${DATE}" \
    "http://${HOST}/${BUCKET}/${FILENAME}")

# Проверяем ответ
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "Файл ${FILENAME} существует в бакете ${BUCKET}"
    exit 0
else
    echo "Файл ${FILENAME} не найден в бакете ${BUCKET}"
    exit 1
fi