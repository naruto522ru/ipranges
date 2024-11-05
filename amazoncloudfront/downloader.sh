#!/bin/bash

set -euo pipefail
set -x


# get from public ranges
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips | jq -r '.CLOUDFRONT_GLOBAL_IP_LIST[],.CLOUDFRONT_REGIONAL_EDGE_IP_LIST[]' | sort -h | uniq > /tmp/amazoncloudfront.json

# save ipv4
grep -v ':' /tmp/amazoncloudfront.json | grep -v "0.0.0.0" | sort -h | uniq > amazoncloudfront/ipv4.txt

# save ipv6
grep ':' /tmp/amazoncloudfront.json > /tmp/amazoncloudfront-ipv6.txt

# sort & uniq
if [[ ! -s /tmp/amazoncloudfront-ipv6.txt ]]; then
    sort -h /tmp/amazoncloudfront-ipv6.txt | uniq > amazoncloudfront/ipv6.txt
fi
