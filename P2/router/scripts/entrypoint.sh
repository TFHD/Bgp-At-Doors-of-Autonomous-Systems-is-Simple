#!/bin/sh
set -e

/vxlan_boot.sh
/usr/lib/frr/frrinit.sh start

exec /bin/sh
