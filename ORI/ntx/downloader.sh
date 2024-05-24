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

get_maintained 'MNT-CZN' > /tmp/ntx.txt || echo 'failed'
get_maintained 'MNT-NTX' >> /tmp/ntx.txt || echo 'failed'
get_routes 'AS50113' >> /tmp/ntx.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/ntx.txt | grep -v "0.0.0.0" > /tmp/ntx-ipv4.txt

# save ipv6
grep ':' /tmp/ntx.txt > /tmp/ntx-ipv6.txt

# sort & uniq
sort -h /tmp/ntx-ipv4.txt | uniq > ORI/ntx/ipv4.txt
sort -h /tmp/ntx-ipv6.txt | uniq > ORI/ntx/ipv6.txt
