#!/bin/bash

# https://www.workplace.com/resources/tech/it-configuration/domain-whitelisting
# https://www.irr.net/docs/list.html
# https://bgp.he.net/search?search%5Bsearch%5D=facebook&commit=Search
# https://github.com/SecOps-Institute/FacebookIPLists/blob/master/facebook_asn_list.lst

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

get_routes 'AS32934' > /tmp/facebook.txt || echo 'failed'
get_routes 'AS54115' >> /tmp/facebook.txt || echo 'failed'
get_routes 'AS63293' >> /tmp/facebook.txt || echo 'failed'
get_routes 'AS149642' >> /tmp/facebook.txt || echo 'failed'
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/resolve-facebook.txt | grep -i [0-9]. >> /tmp/facebook.txt || echo 'failed'
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-facebook.txt | grep -i [0-9]. >> /tmp/facebook.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/facebook.txt > /tmp/facebook-ipv4.txt

# save ipv6
grep ':' /tmp/facebook.txt > /tmp/facebook-ipv6.txt


# sort & uniq
sort -h /tmp/facebook-ipv4.txt | uniq > facebook/ipv4.txt
sort -h /tmp/facebook-ipv6.txt | uniq > facebook/ipv6.txt
