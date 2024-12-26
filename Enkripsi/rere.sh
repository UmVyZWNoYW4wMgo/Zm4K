#!/bin/bash

tempfile=$(mktemp)
password="FN Project ® FunnyVPN & Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02"

pasword=$(echo -e "$password" | base64)

tail -n +2 "$1" | openssl enc -d -aes-256-cbc -pbkdf2 -salt -pass pass:"$pasword" -out "$tempfile" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "Failed to decrypt the script."
    rm -f "$tempfile"
    exit 1
fi

bash $tempfile
rm -fr "$tempfile"