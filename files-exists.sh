#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Использование: $0 <файл-со-списком> <исходный-бакет>"
    exit 1
fi

FILE_LIST="$1"
SOURCE_BUCKET="$2"

if [ ! -s "$FILE_LIST" ]; then
    echo "Ошибка: Файл $FILE_LIST пуст или не существует"
    exit 1
fi

while read filename; do
    if [ ! -z "$filename" ]; then
        ./file-exists.sh "$filename" "$SOURCE_BUCKET"
    fi
done < "$FILE_LIST"