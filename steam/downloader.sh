#!/bin/bash


set -euo pipefail
set -x


# get from Autonomous System
get_routes() {
    whois -h riswhois.ripe.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
}

get_routes 'AS32590' > /tmp/steam.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/steam.txt > /tmp/steam-ipv4.txt

# save ipv6
grep ':' /tmp/steam.txt > /tmp/steam-ipv6.txt


# sort & uniq
sort -h /tmp/steam-ipv4.txt | uniq > steam/ipv4.txt
sort -h /tmp/steam-ipv6.txt | uniq > steam/ipv6.txt
