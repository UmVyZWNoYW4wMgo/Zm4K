#!/bin/bash

# Fungsi untuk mengenkripsi file .sh
encrypt_sh() {
    local file="$1"
    echo "Mengenkripsi file: $file"
#    enc -t bash -i $file -o $file.enc
#    shc -vrf "$file"
     rechan $file $file.enc
    if [ $? -eq 0 ]; then
        rm -f "$file"
        echo "File $file berhasil dienkripsi dan disimpan sebagai ${file%.sh}.enc"
    else
        echo "Gagal mengenkripsi $file"
    fi
}

# Fungsi untuk meng-compile file .go
compile_go() {
    local file="$1"
    echo "Meng-compile file: $file"
    local output="${file%.go}"
    go build -ldflags="-s -w" -o "$output" "$file"
    if [ $? -eq 0 ]; then
        rm -f "$file"
        echo "File $file berhasil dikompilasi dan disimpan sebagai $output"
    else
        echo "Gagal meng-compile $file"
    fi
}

# Fungsi untuk meng-compile file .cpp
compile_cpp() {
    local file="$1"
    echo "Meng-compile file: $file"
    local output="${file%.cpp}"
    g++ -o "$output" "$file"
    if [ $? -eq 0 ]; then
        rm -f "$file"
        echo "File $file berhasil dikompilasi dan disimpan sebagai $output"
    else
        echo "Gagal meng-compile $file"
    fi
}

# Mengecek semua file dalam direktori saat ini
for file in *; do
    if [ -f "$file" ]; then
        case "$file" in
            *.sh)
                encrypt_sh "$file"
                ;;
            *.go)
                compile_go "$file"
                ;;
            *.cpp)
                compile_cpp "$file"
                ;;
            *)
                echo "File $file tidak dikenali. Lewati."
                ;;
        esac
    fi
done
