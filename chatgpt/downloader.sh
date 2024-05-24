#!/bin/bash

set -euo pipefail
set -x

# get domain list another repository
curl -# -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/dns-openai.txt | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' > chatgpt/chatgpt_domain.txt
curl -# -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/ext-dns-openai.txt | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' >> chatgpt/chatgpt_domain.txt

dig @8.8.4.4 -f chatgpt/chatgpt_domain.txt +short A | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | sed '/^1.1.1.1/d' | sed '/^8.8.8.8/d' | sed '/^1.0.0.1/d' | sed '/^8.8.4.4/d' >> /tmp/chatgpt.txt

rm -fv chatgpt/chatgpt_domain.txt

# save ipv4
grep -v ':' /tmp/chatgpt.txt > /tmp/chatgpt-ipv4.txt

# save ipv6
#grep ':' /tmp/chatgpt.txt > /tmp/chatgpt-ipv6.txt

# sort & uniq
sort -h /tmp/chatgpt-ipv4.txt | uniq > chatgpt/ipv4.txt
#sort -h /tmp/chatgpt-ipv6.txt | uniq > chatgpt/ipv6.txt

rm -fv /tmp/chatgpt.txt
