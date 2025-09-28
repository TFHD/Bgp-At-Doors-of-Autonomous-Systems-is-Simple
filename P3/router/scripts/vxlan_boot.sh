#!/bin/sh
set -e

ACCESS_IF=${ACCESS_IF:-eth1}
UNDERLAY_IF=${UNDERLAY_IF:-eth0}
VNI=${VNI:-10}

for i in $(seq 1 20); do
  ip link show ${UNDERLAY_IF} >/dev/null 2>&1 && ip link show ${ACCESS_IF} >/dev/null 2>&1 && break
  sleep 1
done

ip link del vxlan${VNI} 2>/dev/null || true
ip link del br0 2>/dev/null || true

ip link add br0 type bridge
ip link set br0 up
ip link set ${ACCESS_IF} up
ip link set ${ACCESS_IF} master br0

if [ -z "${LOOPBACK_IP}" ]; then
  echo "LOOPBACK_IP not set; skipping VXLAN creation" >&2
  exit 0
fi

ip link add vxlan${VNI} type vxlan id ${VNI} dstport 4789
ip link set vxlan${VNI} up
ip link set vxlan${VNI} master br0

exit 0