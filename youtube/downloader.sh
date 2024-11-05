#!/bin/bash


set -euo pipefail
set -x



# save ipv4
#grep -v ':' youtube/nets.txt > /tmp/youtube-ipv4.txt
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/resolve-youtube.txt | grep -i [0-9]. > /tmp/youtube-ipv4.txt || echo 'failed'
curl -4s --max-time 90 --retry-delay 3 --retry 5 https://raw.githubusercontent.com/antonme/ipnames/master/ext-resolve-youtube.txt | grep -i [0-9]. >> /tmp/youtube-ipv4.txt || echo 'failed'

# save ipv6
# grep ':' youtube/nets.txt > /tmp/youtube-ipv6.txt


# sort & uniq
sort -h /tmp/youtube-ipv4.txt | uniq > youtube/ipv4.txt
# sort -h /tmp/youtube-ipv6.txt | uniq > youtube/ipv6.txt
