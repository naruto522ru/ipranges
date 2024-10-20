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

get_routes 'AS32590' > /tmp/steam.txt || echo 'failed'

dos2unix steam/domain.txt
rm -f /tmp/steam_resolve.txt;
# resolving
# Both Record (IPv4/IPv6)
cat steam/domain.txt | utils/mdig-bolvan --threads=$(nproc) >> /tmp/steam_resolve.txt
# A-Record (IPv4)
#cat steam/domain.txt | utils/mdig-bolvan --family=4 --threads=$(nproc) >> /tmp/steam_resolve.txt
# AAAA-Record (IPv6)
#cat steam/domain.txt | utils/mdig-bolvan --family=6 --threads=$(nproc) >> /tmp/steam_resolve.txt
cat /tmp/steam.txt /tmp/steam_resolve.txt | uniq | sort -u | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | sed '/^1.1.1.1/d' | sed '/^8.8.8.8/d' | sed '/^1.0.0.1/d' | sed '/^8.8.4.4/d' | sponge /tmp/steam.txt

# save ipv4
grep -v ':' /tmp/steam.txt | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | sed '/^1.1.1.1/d' | sed '/^8.8.8.8/d' | sed '/^1.0.0.1/d' | sed '/^8.8.4.4/d' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' > /tmp/steam-ipv4.txt

# save ipv6
grep ':' /tmp/steam.txt | sed 's/ //g' | sed '/^$/d' | uniq | sort -u > /tmp/steam-ipv6.txt

# sort & uniq
sort -k1,1n -k2,2n -k3,3n -k4,4n -T /tmp -h /tmp/steam-ipv4.txt | uniq > steam/ipv4.txt
sort -T /tmp -h /tmp/steam-ipv6.txt | uniq > steam/ipv6.txt
