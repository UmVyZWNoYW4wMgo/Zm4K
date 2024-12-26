#!/bin/bash

[[ -e $(which curl) ]] && grep -q "1.1.1.1" /etc/resolv.conf || { 
    echo "nameserver 1.1.1.1" | cat - /etc/resolv.conf >> /etc/resolv.conf.tmp && mv /etc/resolv.conf.tmp /etc/resolv.conf
}


    # Konfigurasi URL izin
    PERMISSION_URL="https://permision.rerechanstore.eu.org/izin.txt"
    LOCAL_IP=$(curl -s ifconfig.me) # Mendapatkan IP lokal

    # Fungsi menghitung sisa waktu
    calculate_remaining_days() {
        local today=$(date +%s)
        local expired_date=$(date -d "$1" +%s 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Tanggal kadaluwarsa tidak valid."
            exit 1
        fi
        echo $(( (expired_date - today) / 86400 ))
    }

    # Unduh izin dan validasi
    clear
    PERMISSION_DATA=$(curl -s "$PERMISSION_URL" || { echo "Gagal mengunduh izin."; exit 1; })

    # Mencocokkan data berdasarkan IP lokal
    MATCH=$(echo "$PERMISSION_DATA" | grep "###" | grep "$LOCAL_IP")
    if [ -z "$MATCH" ]; then
        echo "Your IP doesn’t have on database"
        exit 1
    fi

    # Ekstraksi data dari baris yang cocok
    USERNAME=$(echo "$MATCH" | awk '{print $2}')
    PERMISSION_IP=$(echo "$MATCH" | awk '{print $3}')
    EXPIRED_DATE=$(echo "$MATCH" | awk '{print $4}')

    # Validasi masa aktif
    REMAINING_DAYS=$(calculate_remaining_days "$EXPIRED_DATE")
    if [ "$REMAINING_DAYS" -lt 0 ]; then
        echo "Izin telah kadaluwarsa."
        exit 1
    fi

    # Output informasi izin
    output() {
        echo "Username: $USERNAME"
        echo "IPv4: $PERMISSION_IP"
        echo "Expired: $EXPIRED_DATE ( $REMAINING_DAYS Days )"
    }

    output

# Detail Hosting
hosting="https://raw.githubusercontent.com/UmVyZWNoYW4wMgo/Zm4K/refs/heads/main"
clear

# Menginstall Core
cd /usr/bin
apt install bzip2 -y
wget https://raw.githubusercontent.com/Rerechan02/Rerechan02/main/v2ray.bz2 ; bzip2 -d v2ray.bz2 ; rm -fr v2ray.bz2 ; clear ; chmod +x v2ray

# Mengkonfigurasi V2ray default
apt install v2ray -y

# Membuat Service
cat> /etc/systemd/system/xray.service << MLBB
[Unit]
Description=V2ray by FunnyVPN
Documentation=https://github.com/v2rayfly/v2ray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/v2ray run -c /etc/v2ray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
MLBB

# Mengambil json
cd /etc/xray/json
mv ws.json /etc/v2ray/config.json

# Mengganti UUID Default V2ray
sed -i "s/rerechan-store/$(xray uuid)/g" /etc/v2ray/config.json

# Mengganti Path Log File
find $(pwd) -type f -exec sed -i 's|/var/log/xray/ws.log|/var/log/v2ray/access.log|g' {} +

# Mengganti Outbound Default
# Mengambil Lokasi Xray Config
XRAY_CONFIG="/etc/v2ray/config.json"

# Mendapatkan nomor baris untuk bagian "outbounds"
line=$(cat /etc/v2ray/config.json | grep -n '"outbounds":' | awk -F: '{print $1}' | head -1)

# Menghapus bagian setelah "outbounds"
sed -i "${line},\$d" /etc/v2ray/config.json
TEXT="
    \"outbounds\": [
    {
      \"protocol\": \"freedom\",
      \"settings\": {}
    },
    {
      \"protocol\": \"blackhole\",
      \"settings\": {},
      \"tag\": \"blocked\"
    }
  ],
  \"routing\": {
    \"rules\": [
      {
        \"type\": \"field\",
        \"ip\": [
         \"0.0.0.0/8\",
          \"10.0.0.0/8\",
          \"100.64.0.0/10\",
          \"169.254.0.0/16\",
          \"172.16.0.0/12\",
          \"192.0.0.0/24\",
          \"192.0.2.0/24\",
          \"192.168.0.0/16\",
          \"198.18.0.0/15\",
          \"198.51.100.0/24\",
          \"203.0.113.0/24\",
          \"::1/128\",
          \"fc00::/7\",
          \"fe80::/10\"
        ],
        \"outboundTag\": \"blocked\"
      },
      {
        \"inboundTag\": [
          \"api\"
        ],
        \"outboundTag\": \"api\",
        \"type\": \"field\"
      },
      {
        \"type\": \"field\",
        \"outboundTag\": \"blocked\",
        \"protocol\": [
          \"bittorrent\"
        ]
      }
    ]
  },
  \"stats\": {},
  \"api\": {
    \"services\": [
      \"StatsService\"
    ],
    \"tag\": \"api\"
  },
  \"policy\": {
    \"levels\": {
      \"0\": {
        \"statsUserDownlink\": true,
        \"statsUserUplink\": true
      }
    },
    \"system\": {
      \"statsInboundUplink\": true,
      \"statsInboundDownlink\": true,
      \"statsOutboundUplink\" : true,
      \"statsOutboundDownlink\" : true
    }
  }
}"
# Menambahkan konfigurasi ke dalam file Xray
echo "$TEXT" >> "$XRAY_CONFIG"

# Reload dan restart Xray service
systemctl daemon-reload
systemctl restart xray

# Permission File Json
cd /etc/v2ray
chmod +x config.json

# Permision Log
mkdir -p /var/log/v2ray
touch /var/log/v2ray/access.log
chown -R root:root /var/log/v2ray
chmod -R 755 /var/log/v2ray

# Menjalanlan service
systemctl daemon-reload
systemctl enable xray
systemctl start xray
systemctl restart xray

# menghapus file dump
rm -f /root/v2ray.sh