#!/bin/bash

set -euo pipefail
set -x

# get domain list another repository
curl -# -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/dns-openai.txt | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' > chatgpt/chatgpt_domain.txt
curl -# -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/ext-dns-openai.txt | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' >> chatgpt/chatgpt_domain.txt
echo 'ab.chatgpt.com
api.openai.com
arena.openai.com
auth.openai.com
auth0.openai.com
beta.api.openai.com
beta.openai.com
blog.openai.com
cdn.oaistatic.com
cdn.openai.com
community.openai.com
contest.openai.com
debate-game.openai.com
discuss.openai.com
files.oaiusercontent.com
gpt3-openai.com
gym.openai.com
help.openai.com
ios.chat.openai.com
jukebox.openai.com
labs.openai.com
microscope.openai.com
oaistatic.com
openai.com
openai.fund
openai.org
platform.api.openai.com
platform.openai.com
spinningup.openai
chat.openai.com
chatgpt.com' >> chatgpt/chatgpt_domain.txt
sort chatgpt/chatgpt_domain.txt | uniq | sponge chatgpt/chatgpt_domain.txt

cat chatgpt/chatgpt_domain.txt | utils/mdig-bolvan --family=4 --threads=$(nproc) | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | sed '/^1.1.1.1/d' | sed '/^8.8.8.8/d' | sed '/^1.0.0.1/d' | sed '/^8.8.4.4/d' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' >> /tmp/chatgpt.txt

rm -fv chatgpt/chatgpt_domain.txt

# save ipv4
grep -v ':' /tmp/chatgpt.txt > /tmp/chatgpt-ipv4.txt

# save ipv6
#grep ':' /tmp/chatgpt.txt > /tmp/chatgpt-ipv6.txt

# sort & uniq
sort -h /tmp/chatgpt-ipv4.txt | uniq > chatgpt/ipv4.txt
#sort -h /tmp/chatgpt-ipv6.txt | uniq > chatgpt/ipv6.txt

rm -fv /tmp/chatgpt.txt
