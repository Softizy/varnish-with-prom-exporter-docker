#!/bin/bash
set -e

trap "exit 1" TERM
export TOP_PID=$$

function missingEnv() {
    echo "Missing env var $1"
    kill -s TERM $TOP_PID
}

# Varnish / Signaller vars check
[[ -z "${ADMIN_PORT}" ]] && missingEnv ADMIN_PORT || AdminPort="${ADMIN_PORT}"
[[ -z "${SIGNALLER_PORT}" ]] && missingEnv SIGNALLER_PORT || SignallerPort="${SIGNALLER_PORT}"
[[ -z "${FRONTEND_NAMESPACE}" ]] && missingEnv FRONTEND_NAMESPACE || FrontendNamespace="${FRONTEND_NAMESPACE}"
[[ -z "${FRONTEND_SERVICE}" ]] && missingEnv FRONTEND_SERVICE || FrontendService="${FRONTEND_SERVICE}"
[[ -z "${FRONTEND_PORT}" ]] && missingEnv FRONTEND_PORT || FrontendPort="${FRONTEND_PORT}"
[[ -z "${BACKEND_NAMESPACE}" ]] && missingEnv BACKEND_NAMESPACE || BackendNamespace="${BACKEND_NAMESPACE}"
[[ -z "${BACKEND_SERVICE}" ]] && missingEnv BACKEND_SERVICE || BackendService="${BACKEND_SERVICE}"
[[ -z "${SECRET_PATH}" ]] && missingEnv SECRET_PATH || SecretPath="${SECRET_PATH}"
[[ -z "${VCL_TEMPLATE}" ]] && missingEnv VCL_TEMPLATE || VclTemplate="${VCL_TEMPLATE}"
[[ -z "${VARNISH_STORAGE}" ]] && missingEnv VARNISH_STORAGE || VarnishStorage="${VARNISH_STORAGE}"

# Prometheus exporter vars check
[[ -z "${PROMETHEUS_EXPORTER_PORT}" ]] && missingEnv PROMETHEUS_EXPORTER_PORT || PrometheusExporterPort="${PROMETHEUS_EXPORTER_PORT}"

/kube-httpcache \
  -admin-addr=0.0.0.0 \
  -admin-port="$AdminPort" \
  -signaller-enable \
  -signaller-port="$SignallerPort" \
  -frontend-watch \
  -frontend-namespace="$FrontendNamespace" \
  -frontend-service="$FrontendService" \
  -frontend-port="$FrontendPort" \
  -backend-watch \
  -backend-namespace="$BackendNamespace" \
  -backend-service="$BackendService" \
  -varnish-secret-file="$SecretPath" \
  -varnish-vcl-template="$VclTemplate" \
  -varnish-storage="$VarnishStorage" \
  &

/usr/sbin/prometheus_varnish_exporter -web.listen-address "0.0.0.0:$PrometheusExporterPort" -web.telemetry-path "/metrics" -web.health-path "/health" &

wait -n

exit $?
