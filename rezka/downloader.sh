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

get_routes 'AS48158' > /tmp/rezka.txt || echo 'failed'
get_routes 'AS58073' >> /tmp/rezka.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/rezka.txt > /tmp/rezka-ipv4.txt

# save ipv6
grep ':' /tmp/rezka.txt > /tmp/rezka-ipv6.txt


# sort & uniq
sort -h /tmp/rezka-ipv4.txt | uniq > rezka/ipv4.txt
sort -h /tmp/rezka-ipv6.txt | uniq > rezka/ipv6.txt
