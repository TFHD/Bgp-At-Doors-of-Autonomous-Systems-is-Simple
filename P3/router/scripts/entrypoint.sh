#!/bin/sh
set -e

# Sysctl et VXLAN restent inchangés...
if [ "${AUTO_VXLAN:-1}" = "1" ] && [ "${ROLE}" = "LEAF" ]; then
  /vxlan_boot.sh || true
fi

if [ "${AUTO_FRR:-1}" = "1" ]; then
  /bootstrap_frr.sh || true
fi

/usr/lib/frr/frrinit.sh start

exec /bin/sh