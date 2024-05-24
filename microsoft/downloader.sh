#!/bin/bash
set -euo pipefail
set -x


curl -4s --max-time 90 --retry-delay 3 --retry 5 https://download.microsoft.com/download/B/2/A/B2AB28E1-DAE1-44E8-A867-4987FE089EBE/msft-public-ips.csv | cut -d',' -f1|awk 'NR > 1'  > /tmp/microsoft.txt

cat /tmp/microsoft.txt | grep -v ":" > /tmp/microsoft-ipv4.txt
cat /tmp/microsoft.txt | grep ":" > /tmp/microsoft-ipv6.txt

sort -h /tmp/microsoft-ipv4.txt | uniq > microsoft/ipv4.txt
sort -h /tmp/microsoft-ipv6.txt | uniq > microsoft/ipv6.txt

