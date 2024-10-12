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
cat spotify/domains.txt | utils/mdig-bolvan --family=4 --threads=$(nproc) | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' >> /tmp/spotify.txt
# Not support IPv6 address for domain's
#cat spotify/domains.txt | utils/mdig-bolvan --family=6 --threads=$(nproc) | grep ":" >> /tmp/spotify.txt

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
