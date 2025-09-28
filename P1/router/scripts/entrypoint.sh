#!/bin/sh
set -e

for daemon in zebra bgpd ospfd isisd; do
    /usr/sbin/$daemon -d -f /etc/quagga/${daemon}.conf -u quagga -g quagga
done

exec /bin/sh