#!/bin/bash

set -euo pipefail
set -x

# get CIDR from list
get_prefix() {
curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/ipv4.txt > /tmp/"$1".txt
curl --max-time 30 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/$NAME_ACCOUNT_GITHUB/ipranges/main/"$1"/ipv6.txt >> /tmp/"$1".txt
}

name_list=rostelecom

get_prefix "$name_list" || echo 'failed'

# save ipv4
grep -v ':' /tmp/"$name_list".txt > /tmp/"$name_list"-ipv4.txt

# save ipv6
#grep ':' /tmp/"$name_list".txt > /tmp/"$name_list"-ipv6.txt

# unmerging ipv4
python utils/unmerge.py /tmp/"$name_list"-ipv4.txt > "$name_list"/ipv4.txt
# Filtering reserved IP addresses
cat "$name_list"/ipv4.txt | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' | sponge "$name_list"/ipv4.txt

# unmerging ipv6
# ...

# sort & uniq
sort -t. -k1,1n -k2,2n -k3,3n -k4,4n "$name_list"/ipv4.txt | uniq | sponge "$name_list"/ipv4.txt
#sort "$name_list"/ipv6.txt | uniq | sponge "$name_list"/ipv6.txt

# compress
cat "$name_list"/ipv4.txt | zstd -o "$name_list"/ipv4.txt.zst && rm -f "$name_list"/ipv4.txt
#cat "$name_list"/ipv6.txt | zstd -o "$name_list"/ipv6.txt.zst && rm -f "$name_list"/ipv6.txt
