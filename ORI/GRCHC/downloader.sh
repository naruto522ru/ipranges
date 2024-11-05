#!/bin/bash

set -euo pipefail
set -x

function cidr2ip {
    # Разделение IP-адреса и маски подсети на отдельные переменные
    IP="${1%/*}"
    MASK="${1#*/}"

    # Количество битов, используемых для маски
    let bits=32-$MASK

    # Конвертация IP-адреса в 32-битное число
    IFS=. read -r i1 i2 i3 i4 <<< "$IP"
    ip=$((i1*256**3+i2*256**2+i3*256+i4))

    # Вычисление первого и последнего IP-адреса в диапазоне
    first=$((ip & ~(2**bits-1)))
    last=$((ip | 2**bits-1))

    # Вывод IP-адресов в диапазоне
    for ((i=$first; i<=$last; i++)); do
        echo $((i>>24)).$(((i>>16)&255)).$(((i>>8)&255)).$((i&255))
    done
}

# get from mnt
get_maintained() {
    whois -h whois.ripe.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
}

# get from Autonomous System
get_routes() {
    whois -h riswhois.ripe.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
}

get_maintained 'CMU_GRCHC-MNT' > /tmp/grchc.txt || echo 'failed'
get_routes 'AS61280' >> /tmp/grchc.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/grchc.txt | grep -v "0.0.0.0" > /tmp/grchc-ipv4.txt

# sort & uniq
sort -h /tmp/grchc-ipv4.txt | uniq > ORI/GRCHC/ipv4.txt

curl --max-time 90 --retry-delay 3 --retry 10 -4 -# https://raw.githubusercontent.com/C24Be/AS_Network_List/main/blacklists/blacklist.txt | tee /tmp/rkn-spider.cidr &>/dev/null

if [[ -f /tmp/rkn-spider.cidr ]]; then
if [[ -s /tmp/rkn-spider.cidr ]]; then
cat /tmp/rkn-spider.cidr | sort -h | uniq | grep -v ':' | tee -i ORI/GRCHC/ipv4.txt
fi
fi
