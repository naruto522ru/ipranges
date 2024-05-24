#!/usr/bin/env bash
zstdcat $(find . -name "*ipv4*.txt.zst") | grep -i [Aa-Zz]
exit 0
