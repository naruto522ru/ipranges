#!/bin/bash
#set -euo pipefail
#set -x


curl -4s --max-time 90 --retry-delay 3 --retry 5 https://download.microsoft.com/download/B/2/A/B2AB28E1-DAE1-44E8-A867-4987FE089EBE/msft-public-ips.csv | cut -d',' -f1|awk 'NR > 1'  > /tmp/microsoft.txt
# resolving
# Both Record (IPv4/IPv6)
cat microsoft/domain.txt | utils/mdig-bolvan --threads=$(nproc) >> /tmp/microsoft.txt
# A-Record (IPv4)
#cat microsoft/domain.txt | utils/mdig-bolvan --family=4 --threads=$(nproc) >> /tmp/microsoft.txt
# AAAA-Record (IPv6)
#cat microsoft/domain.txt | utils/mdig-bolvan --family=6 --threads=$(nproc) >> /tmp/microsoft.txt

cat /tmp/microsoft.txt | grep -v ":" > /tmp/microsoft-ipv4.txt
cat /tmp/microsoft.txt | grep ":" > /tmp/microsoft-ipv6.txt

sort -h /tmp/microsoft-ipv4.txt | uniq | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' > microsoft/ipv4.txt
sort -h /tmp/microsoft-ipv6.txt | uniq > microsoft/ipv6.txt

