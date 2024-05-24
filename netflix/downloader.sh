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

get_routes 'AS55095' > /tmp/netflix.txt || echo 'failed'
get_routes 'AS40027' >> /tmp/netflix.txt || echo 'failed'
get_routes 'AS394406' >> /tmp/netflix.txt || echo 'failed'
get_routes 'AS2906' >> /tmp/netflix.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/netflix.txt > /tmp/netflix-ipv4.txt

# save ipv6
grep ':' /tmp/netflix.txt > /tmp/netflix-ipv6.txt


# sort & uniq
sort -h /tmp/netflix-ipv4.txt | uniq > netflix/ipv4.txt
sort -h /tmp/netflix-ipv6.txt | uniq > netflix/ipv6.txt
