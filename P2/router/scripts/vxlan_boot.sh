#!/bin/sh

for i in $(seq 1 20); do
    ip link show eth0 >/dev/null 2>&1 && ip link show eth1 >/dev/null 2>&1 && break
    sleep 1
done

ip link del vxlan10 2>/dev/null || true
ip link del br0 2>/dev/null || true

ip link add vxlan10 type vxlan id 10 dev eth0 group 239.1.1.1 dstport 4789
ip link set vxlan10 up
ip link add name br0 type bridge
ip link set br0 up
ip link set eth1 master br0
ip link set vxlan10 master br0

exec /bin/sh
