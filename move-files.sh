#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Использование: $0 <файл-со-списком> <исходный-бакет> <целевой-бакет>"
    exit 1
fi

FILE_LIST="$1"
SOURCE_BUCKET="$2"
DEST_BUCKET="$3"

if [ ! -s "$FILE_LIST" ]; then
    echo "Ошибка: Файл $FILE_LIST пуст или не существует"
    exit 1
fi

while read filename; do
    if [ ! -z "$filename" ]; then
        ./move-file.sh "$filename" "$SOURCE_BUCKET" "$DEST_BUCKET"
    fi
done < "$FILE_LIST"