#!/bin/bash

set -euo pipefail
set -x

# get from Autonomous System
get_maintained() {
    whois -h whois.ripe.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
}

get_maintained 'VTB-BANK-MNT' > /tmp/vtb.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/vtb.txt > /tmp/vtb-ipv4.txt

# sort & uniq
sort -h /tmp/vtb-ipv4.txt | uniq > banki/vtb/ipv4.txt
