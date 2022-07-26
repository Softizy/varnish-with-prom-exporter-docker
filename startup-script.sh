#!/bin/bash
set -e

# this will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- varnishd \
	    -F \
	    -f /etc/varnish/default.vcl \
	    -a http=:8080,HTTP \
	    -a proxy=:8443,PROXY \
	    -p feature=+http2 \
	    -s malloc,$VARNISH_SIZE \
	    -n /tmp/varnish \
	    "$@"
fi

exec "$@" &

/usr/sbin/prometheus_varnish_exporter -web.listen-address "0.0.0.0:9131" -web.telemetry-path "/metrics" -web.health-path "/health" &

wait -n

exit $?
