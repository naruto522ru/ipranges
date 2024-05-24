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

get_routes 'AS54113' > /tmp/spotify.txt || echo 'failed'
get_routes 'AS15169' >> /tmp/spotify.txt || echo 'failed'
dos2unix spotify/domains.txt &>/dev/null;
dig @8.8.4.4 -f spotify/domains.txt +short A | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' >> /tmp/spotify.txt
# Not support IPv6 address for domain's
#dig @8.8.4.4 -f spotify/domains.txt +short AAAA | grep ":" >> /tmp/spotify.txt

# Delete Google DNS subnet's
sed -i '/^8.8.4.0/d' /tmp/spotify.txt
sed -i '/^8.8.8.0/d' /tmp/spotify.txt
sed -i '/^8.8.4.4/d' /tmp/spotify.txt
sed -i '/^8.8.8.8/d' /tmp/spotify.txt
sed -i 's/ //g' /tmp/spotify.txt

# save ipv4
grep -v ':' /tmp/spotify.txt > /tmp/spotify-ipv4.txt

# save ipv6
grep ':' /tmp/spotify.txt > /tmp/spotify-ipv6.txt

# sort & uniq
sort -h /tmp/spotify-ipv4.txt | uniq > spotify/ipv4.txt
sort -h /tmp/spotify-ipv6.txt | uniq > spotify/ipv6.txt
