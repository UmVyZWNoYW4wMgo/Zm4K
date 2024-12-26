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


clear
xver=$(xray version | awk '{print $2}' | head -n 1)
domain=$(cat /etc/xray/domain)
ip6=$(curl -sS ipv4.icanhazip.com)
ip4=$(curl -sS ipv6.icanhazip.com)
sshd="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
ws=$(cat /etc/v2ray/config.json | grep "###" | sort | uniq | wc -l)
http=$(cat /etc/xray/json/upgrade.json | grep "###" | sort | uniq | wc -l)
gpc=$(cat /etc/xray/json/grpc.json | grep "###" | sort | uniq | wc -l)
split=$(cat /etc/xray/json/split.json | grep "###" | sort | uniq | wc -l)
uptime=$(uptime | awk '{print $1, $2, $3, $4, $5}')
isp=$(cat /root/.isp)
region=$(cat /root/.region)
clear

#Download/Upload today
dtoday="$(vnstat -i eth0 | grep "today" | awk '{print $2" "substr ($3, 1, 1)}')"
utoday="$(vnstat -i eth0 | grep "today" | awk '{print $5" "substr ($6, 1, 1)}')"
ttoday="$(vnstat -i eth0 | grep "today" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload yesterday
dyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $2" "substr ($3, 1, 1)}')"
uyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $5" "substr ($6, 1, 1)}')"
tyest="$(vnstat -i eth0 | grep "yesterday" | awk '{print $8" "substr ($9, 1, 1)}')"
#Download/Upload current month
dmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $3" "substr ($4, 1, 1)}')"
umon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $6" "substr ($7, 1, 1)}')"
tmon="$(vnstat -i eth0 -m | grep "`date +"%b '%y"`" | awk '{print $9" "substr ($10, 1, 1)}')"
clear

### Warna / Collor jir
export red='\033[0;31m'
export green='\033[0;32m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export NC='\033[0m'
export BICyan='\033[0;36m'

### Status SSH
cek=$(service ssh status | grep active | cut -d ' ' -f5)
if [ "$cek" = "active" ]; then
stat=-f5
else
stat=-f7
fi
ssh=$(service ssh status | grep active | cut -d ' ' $stat)
if [ "$ssh" = "active" ]; then
resh="${green}ON${NC}"
else
resh="${red}OFF${NC}"
fi

### Status XTLS WebSocket
vxws=$(service xray status | grep active | cut -d ' ' $stat)
if [ "$vxws" = "active" ]; then
xws="${green}ON${NC}"
else
xws="${red}OFF${NC}"
fi

### Status XTLS HTTP UPGRADE
vxhttp=$(service xray@upgrade status | grep active | cut -d ' ' $stat)
if [ "$vxhttp" = "active" ]; then
xhttp="${green}ON${NC}"
else
xhttp="${red}OFF${NC}"
fi

### Status XTLS SPLIT HTTP
vxsplit=$(service xray@split status | grep active | cut -d ' ' $stat)
if [ "$vxsplit" = "active" ]; then
xsplit="${green}ON${NC}"
else
xsplit="${red}OFF${NC}"
fi

### Status XTLS gRPC
vxgpc=$(service xray@grpc status | grep active | cut -d ' ' $stat)
if [ "$vxgpc" = "active" ]; then
xgcp="${green}ON${NC}"
else
xgcp="${red}OFF${NC}"
fi

### Status WebSocket ePro
aws=$(service ws status | grep active | cut -d ' ' $stat)
if [ "$aws" = "active" ]; then
pro="${green}ON${NC}"
else
pro="${red}OFF${NC}"
fi

### Status Loadbalance
ngx=$(service nginx status | grep active | cut -d ' ' $stat)
if [ "$ngx" = "active" ]; then
loadbalance="${green}ON${NC}"
else
loadbalance="${red}OFF${NC}"
fi
rechan=$(output)
clear
echo -e "
${NC}
===================================
<=   MENU MANAGEMENT PANEL VPN   =>
===================================
VERSION XTLS : $xver
DOMAIN SERVER: $domain
IP SERVER    : $ip4 / $ip6
Uptime       : $uptime
ISP / REGION : $isp / $region
===================================
         Total Account

SSH SERVER   : $sshd
XTLS WS      : $ws
XTLS HTTP UP : $http
XTLS SPLIT   : $split
XTLS gRPC    : $gpc
===================================
SSH: $resh | WS: $xws | HTTP: $xhttp
SPLIT: $xsplit | gRPC: $xgcp | ePRO: $pro
Loadbalance: $loadbalance
===================================

1. Menu SSH     4. Menu SlowDNS
2. Menu XTLS    5. Menu Backup
3. Menu Domain  6. Menu Bot Telegram

7. Menu L2TP    8. Menu Wireguard
       9.  Menu NoobzVPN
       10. Menu System
===================================
Today${NC}: ${red}$ttoday$NC Yesterday${NC}: ${red}$tyest$NC This month${NC}: ${red}$tmon$NC $NC
===================================
${rechan}
===================================
 [   PRESS CTRL  +  C TO EXIT    ]
===================================
"
read -p "Input Option: " opw
case $opw in
1) clear ; menu-ssh ;;
2) clear ; menu-x ;;
3) clear ; dm-menu ;;
4) clear ; menu-dnstt ;;
5) clear ; bmenu ;;
6) clear ; menu-bot ;;
7) clear ; xl2tp ;;
8) clear ; menu-wg ;;
9) clear ; menu-noobz ;;
10) clear ; menu-system ;;
*) menu ;;
esac
