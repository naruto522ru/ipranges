#!/usr/bin/env python3
import argparse
import netaddr


def split_generator(obj, buf):
    while True:
        a = obj.readlines(buf)
        if a != []:
            yield a
        else:
            break


def preres_generator(obj):
    for i in obj:
        yield netaddr.cidr_merge(i)


def main():
    parser = argparse.ArgumentParser(description='Merge IP addresses into the smallest possible list of CIDRs.')
    parser.add_argument('--source', nargs='?', type=argparse.FileType('r'), required=True, help='Source file path')
    parser.add_argument('--chunk', '-c', required=True)
    args = parser.parse_args()
    split = split_generator(args.source, int(args.chunk))
    preres = preres_generator(split)
    res = []

    for i in preres:
        for z in i:
            res.append(z)
    for i in netaddr.cidr_merge(res):
        print(i)


if __name__ == '__main__':
    main()
