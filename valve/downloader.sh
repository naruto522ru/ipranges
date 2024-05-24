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

get_routes 'AS32590' > /tmp/valve.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/valve.txt > /tmp/valve-ipv4.txt

# save ipv6
grep ':' /tmp/valve.txt > /tmp/valve-ipv6.txt


# sort & uniq
sort -h /tmp/valve-ipv4.txt | uniq > valve/ipv4.txt
sort -h /tmp/valve-ipv6.txt | uniq > valve/ipv6.txt
