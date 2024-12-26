#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_script> <output_encrypted_script>"
    exit 1
fi

input_script="$1"
output_script="$2"
password="FN Project ® FunnyVPN & Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02 @Rerechan02"

pasword=$(echo -e "$password" | base64)

openssl enc -aes-256-cbc -salt -pbkdf2 -in "$input_script" -out "$output_script" -pass pass:"$pasword"

sed -i '1i#!/usr/bin/rere' "$output_script"
chmod +x ${output_script}

echo "Script encrypted successfully: $output_script"