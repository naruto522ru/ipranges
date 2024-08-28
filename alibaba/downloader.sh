#!/bin/bash

set -euo pipefail
set -x

python utils/arin-org.py AL-3 > /tmp/alibaba.txt
whois -h whois.apnic.net "TAOBAO"| rg inetnum|sort -h|uniq|awk '{print $2" "$4}'|python utils/ipcalc.py >>/tmp/alibaba.txt
whois -h whois.apnic.net "TAOBAO"| grep inet6num| awk '{print $2}' >> /tmp/alibaba.txt

# save ipv4
grep -v ':' /tmp/alibaba.txt > /tmp/alibaba-ipv4.txt

# save ipv6
grep ':' /tmp/alibaba.txt > /tmp/alibaba-ipv6.txt


# sort & uniq
sort -h /tmp/alibaba-ipv4.txt | uniq > alibaba/ipv4.txt
sort -h /tmp/alibaba-ipv6.txt | uniq > alibaba/ipv6.txt
