#!/bin/bash

#set -euo pipefail
set -x

# get from mnt
get_maintained() {
    whois -h whois.ripe.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i mnt-by $1" | rg '^route' | awk '{ print $2; }'
}

# get from Autonomous System
get_routes() {
    whois -h riswhois.ripe.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.radb.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h rr.ntt.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.rogerstelecom.net -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
    whois -h whois.bgp.net.br -- "-i origin $1" | rg '^route' | awk '{ print $2; }'
}

#get_routes 'AS49544' > /tmp/discord.txt || echo 'failed' #AS i3D.net B.V
#get_maintained '' >> /tmp/discord.txt || echo 'failed'

# domains
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://gist.githubusercontent.com/AndyIsHereBoi/bf57d7fa1661c82b4a7f5987e56420bf/raw/7ef7bc308d36bcd1ad5aff42de6c43c838873563/as%2520of%25209-2-2024 | grep -vEe '(ip|city|region|country|org)' | sed 's/,//g' | sed 's/{//g' | sed 's/}//g' | sed 's/"//g' | sed 's/]//g' | sed 's/dns://g' | sed '/:\[/d' | sed 's/ //g' | uniq | sort -u > discord/domain.txt
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/refs/heads/master/rule/Shadowrocket/Discord/Discord.list | sed '/USER-AGENT,/d' | sed '/DOMAIN-KEYWORD/d' | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed '/IP-CIDR/d' | sed '/@/d' | sed 's/full://g' | sed '/:/d' | sed 's/DOMAIN,//g' >> discord/domain.txt
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/v2fly/domain-list-community/refs/heads/master/data/discord | sed 's/ //g' | sed -r '/^\s*$/d' | sed '/!/d' | sed '/!!/d' | sed '/#/d' | sed 's/DOMAIN-SUFFIX,//g' | sed 's/^https\?:\/\///g' | sed 's/full://g' | sed '/IP-CIDR/d' | sed '/@/d' | sed '/:/d' >> discord/domain.txt
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/voice_domains/discord-voice-domains-list https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/main_domains/discord-main-domains-list | sed 's/ //g' | uniq | sort -u >> discord/domain.txt
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/sdnv0x4d/ip-lists/refs/heads/master/discord/discord_domains.txt | sed 's/ //g' | sed '/^$/d' | uniq | sort -u >> discord/domain.txt
dos2unix discord/domain.txt
cat discord/domain.txt | sed '/.solutions/d' | sed '/airhorn/d' | sed '/anime/d' | uniq | sort -u | sponge discord/domain.txt && sed -i '/^$/d' discord/domain.txt

rm -f /tmp/discord_resolve.txt;
# resolving
# Both Record (IPv4/IPv6)
cat discord/domain.txt | utils/mdig-bolvan --threads=$(nproc) >> /tmp/discord_resolve.txt
# A-Record (IPv4)
#cat discord/domain.txt | utils/mdig-bolvan --family=4 --threads=$(nproc) >> /tmp/discord_resolve.txt
# AAAA-Record (IPv6)
#cat discord/domain.txt | utils/mdig-bolvan --family=6 --threads=$(nproc) >> /tmp/discord_resolve.txt

# ip's
rm -f /tmp/ips_discord.txt /tmp/voice_server1.txt /tmp/voice_server2.txt;
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://gist.githubusercontent.com/AndyIsHereBoi/bf57d7fa1661c82b4a7f5987e56420bf/raw/7ef7bc308d36bcd1ad5aff42de6c43c838873563/as%2520of%25209-2-2024 > /tmp/voice_server1.txt
cat /tmp/voice_server1.txt | grep -vEe '(ip|city|region|country|org)' | sed 's/,//g' | sed 's/{//g' | sed 's/}//g' | sed 's/"//g' | sed 's/]//g' | sed 's/dns://g' | sed '/:\[/d' | sed 's/ //g' | uniq | sort -u > /tmp/ips_discord.txt
curl --max-time 180 --retry-delay 3 --retry 10 -4s -# https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/master/discord-voice-ip-list > /tmp/voice_server2.txt
#https://raw.githubusercontent.com/GhostRooter0953/discord-voice-ips/refs/heads/master/discord-voice-ip-list
cat /tmp/voice_server2.txt | uniq | sort -u >> /tmp/ips_discord.txt
dos2unix /tmp/ips_discord.txt
cat /tmp/ips_discord.txt /tmp/discord_resolve.txt | uniq | sort -u > /tmp/discord.txt

# save ipv4
grep -v ':' /tmp/discord.txt | sed '/[A-Za-z]/d' | sed 's/ //g' | sed '/^$/d' | sed '/^0.0.0.0/d' | sed '/^127.0.0.1/d' | sed '/^1.1.1.1/d' | sed '/^8.8.8.8/d' | sed '/^1.0.0.1/d' | sed '/^8.8.4.4/d' | grepcidr -v '0.0.0.0/8' | grepcidr -v '0.0.0.0/32' | grepcidr -v '10.0.0.0/8' | grepcidr -v '100.64.0.0/10' | grepcidr -v '127.0.0.0/8' | grepcidr -v '169.254.0.0/16' | grepcidr -v '172.16.0.0/12' | grepcidr -v '192.0.0.0/24' | grepcidr -v '192.0.0.0/29' | grepcidr -v '192.0.0.170/32' | grepcidr -v '192.0.0.171/32' | grepcidr -v '192.0.2.0/24' | grepcidr -v '192.88.99.0/24' | grepcidr -v '192.88.99.1/32' | grepcidr -v '192.168.0.0/16' | grepcidr -v '198.51.100.0/24' | grepcidr -v '198.18.0.0/15' | grepcidr -v '203.0.113.0/24' | grepcidr -v '224.0.0.0/4' | grepcidr -v '240.0.0.0/4' | grepcidr -v '255.255.255.255/32' > /tmp/discord-ipv4.txt

# save ipv6
grep ':' /tmp/discord.txt > /tmp/discord-ipv6.txt

# sort & uniq
sort -k1,1n -k2,2n -k3,3n -k4,4n -T /tmp -h /tmp/discord-ipv4.txt | uniq > discord/ipv4.txt
sort -h /tmp/discord-ipv6.txt | uniq > discord/ipv6.txt
