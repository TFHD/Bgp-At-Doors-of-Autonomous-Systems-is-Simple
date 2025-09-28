#!/bin/sh
set -e

ROLE=${ROLE:-LEAF}
ASN=${ASN:-1}
VNI=${VNI:-10}
UNDERLAY_IF=${UNDERLAY_IF:-eth0}
ETH_IP=$(ip -4 -o addr show ${UNDERLAY_IF} | awk '{print $4}' | cut -d/ -f1)
LOOPBACK_IP=${LOOPBACK_IP:-1.1.1.0}
ETH0_IP_CIDR=${ETH0_IP_CIDR:-10.1.1.1/30}
ETH1_IP_CIDR=${ETH1_IP_CIDR:-10.1.1.6/30}
ETH2_IP_CIDR_RR=${ETH2_IP_CIDR_RR:-10.1.1.9/30}

if [ -z "${LOOPBACK_IP}" ]; then
  echo "[bootstrap_frr] LOOPBACK_IP is required" >&2
  exit 1
fi

mkdir -p /etc/frr

{
  echo "frr defaults traditional"
  echo "hostname Router"
  echo "no ipv6 forwarding"
  echo "service integrated-vtysh-config"
} > /etc/frr/frr.conf


if [ "$ROLE" = "RR" ]; then
  # ---- host1.sh ----
  {
    echo "interface eth0"
    echo " ip address ${ETH0_IP_CIDR}"
    echo " ip ospf area 0"
    echo "!"
    echo "interface eth1"
    echo " ip address ${ETH1_IP_CIDR}"
    echo " ip ospf area 0"
    echo "!"
    echo "interface eth2"
    echo " ip address ${ETH2_IP_CIDR_RR}"
    echo " ip ospf area 0"
    echo "!"
    echo "interface lo"
    echo " ip address ${LOOPBACK_IP}/32"
    echo " ip ospf area 0"
    echo "!"
    echo "router bgp ${ASN}"
    echo " neighbor ibgp peer-group"
    echo " neighbor ibgp remote-as ${ASN}"
    echo " neighbor ibgp update-source lo"
    echo " neighbor 1.1.1.2 peer-group ibgp"
    echo " neighbor 1.1.1.3 peer-group ibgp"
    echo " neighbor 1.1.1.4 peer-group ibgp"
    echo " address-family l2vpn evpn"
    echo "  neighbor ibgp activate"
    echo "  neighbor ibgp route-reflector-client"
    echo " exit-address-family"
    echo "router ospf"
  } >> /etc/frr/frr.conf

else
  {
    echo "interface ${UNDERLAY_IF}"
    echo " ip address ${ETH_IP}/30"
    echo " ip ospf area 0"
    echo "!"
    echo "interface lo"
    echo " ip address ${LOOPBACK_IP}/32"
    echo " ip ospf area 0"
    echo "!"
    echo "router bgp ${ASN}"
    echo " neighbor ${RR_IP} remote-as ${ASN}"
    echo " neighbor ${RR_IP} update-source lo"
    echo "!"
    echo " address-family l2vpn evpn"
    echo "  neighbor ${RR_IP} activate"
    echo "    advertise-all-vni"
    echo " exit-address-family"
    echo "router ospf"
  } >> /etc/frr/frr.conf
fi

exit 0
