# syntax=docker/dockerfile:1.26

FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS exporter-builder

ARG TARGETARCH
ARG TARGETOS

# Upstream publishes only an amd64 archive for 1.6.1. Build the exact tagged
# source for the requested image platform instead of copying that archive into
# every manifest in the multi-architecture image.
WORKDIR /src
ADD --checksum=sha256:2af8563772d0e3088749021d957a24668f8c323d793f37df5fcd735ab0d216c4 \
    https://codeload.github.com/jonnenauha/prometheus_varnish_exporter/tar.gz/88a7ace6e2128d902f8d54f4ca053d48881f0c7c \
    /tmp/prometheus_varnish_exporter.tar.gz
RUN set -eux; \
    tar -xzf /tmp/prometheus_varnish_exporter.tar.gz --strip-components=1; \
    CGO_ENABLED=0 GOOS="$TARGETOS" GOARCH="$TARGETARCH" go build \
      -trimpath \
      -ldflags="-s -w -X main.Version=1.6.1 -X main.VersionHash=88a7ace6e2128d902f8d54f4ca053d48881f0c7c" \
      -o /out/prometheus_varnish_exporter .

FROM varnish:8.0

LABEL org.opencontainers.image.authors="tech@softizy.com"
LABEL org.opencontainers.image.source="https://github.com/Softizy/varnish-with-prom-exporter-docker"

USER root

ENV VARNISH_EXPORTER_VERSION=1.6.1

COPY startup-script.sh /startup-script.sh
COPY --from=exporter-builder /out/prometheus_varnish_exporter /usr/sbin/prometheus_varnish_exporter

RUN set -eux; \
    chmod +x /startup-script.sh;

ENTRYPOINT ["/startup-script.sh"]

USER varnish
EXPOSE 8080 8443 9131
