#!/bin/bash

find . -name copy_as.sh

FILE1=$(find . -name copy_as.sh | sed 's/copy_as.sh/ipv4_merged.txt/g')
FILE2=$(find . -name copy_as.sh | sed 's/copy_as.sh/ipv4.txt/g')

cp -fv "$FILE1" "$FILE2"
