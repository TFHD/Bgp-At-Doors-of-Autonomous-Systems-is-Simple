FROM quay.io/frrouting/frr:master

ENV DAEMONS="zebra bgpd ospfd isisd"
COPY ./conf/daemons.conf /etc/frr/daemons
COPY conf/zebra.conf /etc/frr/
COPY conf/bgpd.conf /etc/frr/
COPY conf/ospfd.conf /etc/frr/
COPY conf/isisd.conf /etc/frr/

COPY scripts/entrypoint.sh /entrypoint.sh
COPY scripts/vxlan_boot.sh /vxlan_boot.sh

RUN chmod +x /entrypoint.sh
RUN chmod +x /vxlan_boot.sh

ENTRYPOINT ["/entrypoint.sh"]

