# IPRanges

List all IP ranges from: Google, Bing, Amazon, Microsoft, Azure, Oracle, DigitalOcean, GitHub, Facebook, Twitter, Linode, Yandex, Vkontakte, Telegram, Netflix, Valve, Spotify, ChatGPT, YouTube with regular auto-updates.

All lists are obtained from public sources.

## List types

`ipv4.txt`/`ipv6.txt` – the list of addresses (IPv4 or IPv6), which is the result of parsing one or more sources.

`ipv4_merged.txt`/`ipv6_merged.txt` – list of addresses, after combining them into the smallest possible list of CIDRs.

`ipv4.txt.zst` - compressed unmerged IPv4 address list by zst algorithm

## How get list unmerged on devices:

#### with curl:
```bash
curl --retry 3 -s https://raw.githubusercontent.com/naruto522ru/ipranges/main/SERVICE_NAME/ipv4.txt.zst | zstd -d > filename.txt
```

#### with wget:
```bash
wget -t 3 -qO - https://raw.githubusercontent.com/naruto522ru/ipranges/main/SERVICE_NAME/ipv4.txt.zst | zstd -d > filename.txt
```

## See also repository:

https://github.com/naruto522ru/ipranges-shadowsocks
