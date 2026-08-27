#!/bin/sh
set -eu

workflow=".github/workflows/docker-push.yml"
image="ghcr.io/softizy/varnish-with-prom-exporter-docker"

if ! grep -Fxq "            ${image}" "$workflow"; then
  echo "ERROR: the publication workflow must target ${image}" >&2
  exit 1
fi

if grep -Eq '^[[:space:]]+softizy/varnish-with-prom-exporter-docker$' "$workflow" || \
   grep -Fq 'Login to DockerHub' "$workflow"; then
  echo "ERROR: Docker Hub credentials must not gate the production GHCR publication" >&2
  exit 1
fi

if ! grep -Fq 'registry: ghcr.io' "$workflow"; then
  echo "ERROR: the publication workflow must authenticate to GHCR" >&2
  exit 1
fi

if ! grep -Fq 'push: ${{ github.event_name != '\''pull_request'\'' }}' "$workflow"; then
  echo "ERROR: branch and tag events must publish the tested image" >&2
  exit 1
fi

printf '%s\n' 'GHCR publication contract is valid.'
