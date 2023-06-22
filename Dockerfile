FROM varnish:7.3

LABEL org.opencontainers.image.authors="tech@softizy.com"
LABEL org.opencontainers.image.source="https://github.com/Softizy/varnish-with-prom-exporter-docker"

USER root

ENV VARNISH_EXPORTER_VERSION=1.6.1

ADD https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/${VARNISH_EXPORTER_VERSION}/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz /tmp
COPY startup-script.sh /startup-script.sh

RUN set -eux; \
    tar zxvf /tmp/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz -C /tmp; \
    mv /tmp/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64/prometheus_varnish_exporter /usr/sbin/; \
    chmod +x /startup-script.sh;

ENTRYPOINT ["/startup-script.sh"]

USER varnish
EXPOSE 8080 8443 9131
