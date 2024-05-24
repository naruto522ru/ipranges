import ipaddress
import sys

def unmerge_subnet(subnet):
    """
    Функция для разбора подсетей.

    Аргумент:
    subnet: str - строка с записью подсети в формате "адрес/маска"

    Возвращает:
    Генератор IP-адресов в подсети
    """
    network = ipaddress.ip_network(subnet, strict=False)

    return (str(ip) for ip in network.hosts())

if len(sys.argv) != 2:
    print("Usage: python script.py <path_to_file>")
    sys.exit(1)

file_path = sys.argv[1]
try:
    with open(file_path, 'r') as file:
        for line in file:
            subnet = line.strip()
            ip_generator = unmerge_subnet(subnet)
            for ip in ip_generator:
                print(ip)
except FileNotFoundError:
    print("Файл не найден.")
    sys.exit(1)
