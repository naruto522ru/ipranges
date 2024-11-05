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

get_maintained 'vdsina-mnt' > /tmp/vdsina.txt || echo 'failed'
get_maintained 'ru-vdsina-1-mnt' >> /tmp/vdsina.txt || echo 'failed'
get_maintained 'ru-vpsville1-1-mnt' >> /tmp/vdsina.txt || echo 'failed'
get_routes 'AS48282' >> /tmp/vdsina.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/vdsina.txt | grep -v "0.0.0.0" > /tmp/vdsina-ipv4.txt

# save ipv6
grep ':' /tmp/vdsina.txt > /tmp/vdsina-ipv6.txt

# sort & uniq
sort -h /tmp/vdsina-ipv4.txt | uniq > ORI/vdsina/ipv4.txt
sort -h /tmp/vdsina-ipv6.txt | uniq > ORI/vdsina/ipv6.txt
