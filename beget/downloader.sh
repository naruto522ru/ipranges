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

get_routes 'AS198610' > /tmp/beget.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/beget.txt > /tmp/beget-ipv4.txt

# save ipv6
grep ':' /tmp/beget.txt > /tmp/beget-ipv6.txt


# sort & uniq
sort -h /tmp/beget-ipv4.txt | uniq > beget/ipv4.txt
sort -h /tmp/beget-ipv6.txt | uniq > beget/ipv6.txt
