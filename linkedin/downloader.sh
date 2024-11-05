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

# Source AS number https://github.com/SecOps-Institute/LinkedInIPLists/blob/af4e7d4b42c2a19e30e35899304f4f2cfafc0e61/linkedin_asn_list.lst
get_routes 'AS13443' > /tmp/linkedin.txt || echo 'failed'
get_routes 'AS14413' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS20049' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS20366' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS40793' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS55163' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS132406' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS132466' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS137709' >> /tmp/linkedin.txt || echo 'failed'
get_routes 'AS202745' >> /tmp/linkedin.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/linkedin.txt > /tmp/linkedin-ipv4.txt

# save ipv6
grep ':' /tmp/linkedin.txt > /tmp/linkedin-ipv6.txt

# sort & uniq
sort -h /tmp/linkedin-ipv4.txt | uniq > linkedin/ipv4.txt
sort -h /tmp/linkedin-ipv6.txt | uniq > linkedin/ipv6.txt
