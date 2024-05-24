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

get_maintained 'APNIC-HM' > /tmp/huaweicloud.txt || echo 'failed'
get_routes 'AS136907' >> /tmp/huaweicloud.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/huaweicloud.txt | grep -v "0.0.0.0" | sed '/rs-/d' | sed '/RS-/d' > /tmp/huaweicloud-ipv4.txt

# save ipv6
grep ':' /tmp/huaweicloud.txt | sed '/rs-/d' | sed '/RS-/d' > /tmp/huaweicloud-ipv6.txt

# sort & uniq
sort -h /tmp/huaweicloud-ipv4.txt | uniq > huaweicloud/ipv4.txt
sort -h /tmp/huaweicloud-ipv6.txt | uniq > huaweicloud/ipv6.txt
