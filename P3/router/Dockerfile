FROM quay.io/frrouting/frr:master

ENV DAEMONS="zebra bgpd ospfd isisd"
COPY ./conf/daemons.conf /etc/frr/daemons

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/vxlan_boot.sh /vxlan_boot.sh
COPY scripts/bootstrap_frr.sh /bootstrap_frr.sh
RUN chmod +x /entrypoint.sh /vxlan_boot.sh /bootstrap_frr.sh

ENTRYPOINT ["/entrypoint.sh"]