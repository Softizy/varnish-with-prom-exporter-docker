FROM quay.io/mittwald/kube-httpcache:stable as kube-httpcache
FROM varnish:7.1 as final

LABEL org.opencontainers.image.authors="tech@softizy.com"
LABEL org.opencontainers.image.source="https://github.com/Softizy/varnish-with-prom-exporter-docker"

USER root

ENV VARNISH_EXPORTER_VERSION=1.6.1

ADD https://github.com/jonnenauha/prometheus_varnish_exporter/releases/download/${VARNISH_EXPORTER_VERSION}/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz /tmp
COPY --from=kube-httpcache /kube-httpcache /kube-httpcache
COPY startup-script.sh /startup-script.sh

RUN set -eux; \
    tar zxvf /tmp/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64.tar.gz -C /tmp; \
    mv /tmp/prometheus_varnish_exporter-${VARNISH_EXPORTER_VERSION}.linux-amd64/prometheus_varnish_exporter /usr/sbin/; \
    chmod +x /startup-script.sh;

USER varnish

ENV ADMIN_PORT=6083
ENV SIGNALLER_PORT=8090
ENV FRONTEND_NAMESPACE=""
ENV FRONTEND_SERVICE=""
ENV FRONTEND_PORT=8080
ENV BACKEND_NAMESPACE=""
ENV BACKEND_SERVICE=""
ENV SECRET_PATH=/etc/varnish/k8s-secret/secret
ENV VCL_TEMPLATE=/etc/varnish/tmpl/default.vcl.tmpl
ENV VARNISH_STORAGE="malloc,128M"

ENTRYPOINT []
CMD ["/startup-script.sh"]
