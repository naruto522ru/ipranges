#!/bin/bash

set -euo pipefail
set -x


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

get_maintained 'RUNIC-MNT' > /tmp/ru-center.txt || echo 'failed'
get_routes 'AS48287' >> /tmp/ru-center.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/ru-center.txt | grep -v "0.0.0.0" > /tmp/ru-center-ipv4.txt

# save ipv6
grep ':' /tmp/ru-center.txt > /tmp/ru-center-ipv6.txt

# sort & uniq
sort -h /tmp/ru-center-ipv4.txt | uniq > ORI/ru-center/ipv4.txt
sort -h /tmp/ru-center-ipv6.txt | uniq > ORI/ru-center/ipv6.txt
