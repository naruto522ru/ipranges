#!/bin/bash

# https://support.google.com/a/answer/60764
# https://cloud.google.com/compute/docs/faq#find_ip_range
# From: https://github.com/pierrocknroll/googlecloud-iprange/blob/master/list.sh
# From: https://gist.github.com/jeffmccune/e7d635116f25bc7e12b2a19efbafcdf8
# From: https://gist.github.com/n0531m/f3714f6ad6ef738a3b0a

set -euo pipefail
set -x



# get from public ranges
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://www.gstatic.com/ipranges/goog.txt > /tmp/goog.txt
#curl -4s --max-time 90 --retry-delay 3 --retry 5 https://www.gstatic.com/ipranges/cloud.json > /tmp/cloud.json

# Public GoogleBot IP ranges
# From: https://developers.google.com/search/docs/advanced/crawling/verifying-googlebot
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://developers.google.com/search/apis/ipranges/googlebot.json > /tmp/googlebot.json

# get from netblocks
txt="$(dig TXT _netblocks.google.com +short @127.0.0.53 | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32')"
idx=2
while [[ -n "${txt}" ]]; do
  echo "${txt}" | tr '[:space:]+' "\n" | grep ':' | cut -d: -f2- >> /tmp/netblocks.txt
  txt="$(dig TXT _netblocks${idx}.google.com +short @127.0.0.53 | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32')"
  ((idx++))
done

# get from other netblocks
get_dns_spf() {
   dig @8.8.8.8 +short txt "$1" |
   tr ' ' '\n' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' |
   while read entry; do
      case "$entry" in
             ip4:*) echo "${entry#*:}" ;;
             ip6:*) echo "${entry#*:}" ;;
         include:*) get_dns_spf "${entry#*:}" ;;
      esac
   done
}

#get_dns_spf "_cloud-netblocks.googleusercontent.com" >> /tmp/netblocks.txt
get_dns_spf "_spf.google.com" >> /tmp/netblocks.txt


# save ipv4
grep -v ':' /tmp/goog.txt | grep -v "0.0.0.0" > /tmp/google-ipv4.txt
#jq '.prefixes[] | [.ipv4Prefix][] | select(. != null)' -r /tmp/cloud.json >> /tmp/google-ipv4.txt
jq '.prefixes[] | [.ipv4Prefix][] | select(. != null)' -r /tmp/googlebot.json >> /tmp/google-ipv4.txt
grep -v ':' /tmp/netblocks.txt >> /tmp/google-ipv4.txt
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/resolve-google.txt >> /tmp/google-ipv4.txt || echo 'failed'
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-google.txt >> /tmp/google-ipv4.txt || echo 'failed'
sed -i '/^0.0.0.0/d' /tmp/google-ipv4.txt
sed -i '/^127.0.0.1/d' /tmp/google-ipv4.txt

# save ipv6
grep ':' /tmp/goog.txt > /tmp/google-ipv6.txt
#jq '.prefixes[] | [.ipv6Prefix][] | select(. != null)' -r /tmp/cloud.json >> /tmp/google-ipv6.txt
jq '.prefixes[] | [.ipv6Prefix][] | select(. != null)' -r /tmp/googlebot.json >> /tmp/google-ipv6.txt
grep ':' /tmp/netblocks.txt >> /tmp/google-ipv6.txt


# sort & uniq
sort -h /tmp/google-ipv4.txt | uniq > google/ipv4.txt
sort -h /tmp/google-ipv6.txt | uniq > google/ipv6.txt

# get from Autonomous System
get_routes() {
    whois -h riswhois.ripe.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
}

get_routes 'AS36040' > /tmp/google_as.txt || echo 'failed'

# save ipv4
grep -v ':' /tmp/google_as.txt > /tmp/google_as-ipv4.txt

# save ipv6
grep ':' /tmp/google_as.txt > /tmp/google_as-ipv6.txt

cat google/ipv4.txt /tmp/google_as-ipv4.txt | sort -h | uniq > /tmp/google_both_ipv4.txt

rm -f google/ipv4.txt /tmp/google_as-ipv4.txt;

# unmerging ipv4 and exclude DNS address blocks,reserved IP subnet's
python utils/unmerge.py /tmp/google_both_ipv4.txt | grepcidr -v '8.8.8.0/24' | grepcidr -v '8.8.4.0/24' | grepcidr -v '8.8.8.8/32' | grepcidr -v '8.8.4.4/32' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' > /tmp/google_both_ipv4_unmerging.txt

# sort & uniq unmerging
sort -h -t. -k1,1n -k2,2n -k3,3n -k4,4n /tmp/google_both_ipv4_unmerging.txt | uniq > google/ipv4.txt
