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

get_maintained 'us-zenlayer-1-mnt' > /tmp/zenlayer.txt || echo 'failed'
get_routes 'AS21859' >> /tmp/zenlayer.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/zenlayer.txt | grep -v "0.0.0.0" > /tmp/zenlayer-ipv4.txt

# save ipv6
grep ':' /tmp/zenlayer.txt > /tmp/zenlayer-ipv6.txt

# sort & uniq
sort -h /tmp/zenlayer-ipv4.txt | uniq > zenlayer/ipv4.txt
sort -h /tmp/zenlayer-ipv6.txt | uniq > zenlayer/ipv6.txt
