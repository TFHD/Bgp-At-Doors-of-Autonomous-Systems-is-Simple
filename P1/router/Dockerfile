FROM alpine:latest

RUN apk update && apk add quagga busybox

RUN mkdir -p /var/run/quagga /etc/quagga && \
    chown quagga:quagga /var/run/quagga /etc/quagga

COPY conf/zebra.conf /etc/quagga/
COPY conf/bgpd.conf /etc/quagga/
COPY conf/ospfd.conf /etc/quagga/
COPY conf/isisd.conf /etc/quagga/
COPY conf/daemons /etc/quagga/daemons

RUN chown quagga:quagga /etc/quagga/*

# Script d'entrée pour lancer tous les services
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2601 2604 2605 2606 179

ENTRYPOINT ["/entrypoint.sh"]
