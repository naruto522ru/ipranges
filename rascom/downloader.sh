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

get_maintained 'RASCOM-MNT' | grep -v 'route-set' | grep "/" > /tmp/rascom.txt || echo 'failed'


# save ipv4
grep -v ':' /tmp/rascom.txt > /tmp/rascom-ipv4.txt

# save ipv6
grep ':' /tmp/rascom.txt > /tmp/rascom-ipv6.txt


# sort & uniq
sort -h /tmp/rascom-ipv4.txt | uniq > rascom/ipv4.txt
sort -h /tmp/rascom-ipv6.txt | uniq > rascom/ipv6.txt
