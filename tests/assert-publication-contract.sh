#!/bin/sh
set -eu

workflow="${WORKFLOW:-.github/workflows/docker-push.yml}"
image="ghcr.io/softizy/varnish-with-prom-exporter-docker"

if grep -R -Eq 'DOCKERHUB_(USERNAME|TOKEN)|destination_container_repo:[[:space:]]*softizy/varnish-with-prom-exporter-docker' .github/workflows; then
  echo "ERROR: obsolete Docker Hub credentials must not remain in repository workflows" >&2
  exit 1
fi

docker_job="$(awk '
  /^  docker:$/ { in_job=1 }
  in_job && $0 !~ /^  docker:$/ && /^  [A-Za-z0-9_-]+:$/ { exit }
  in_job { print }
' "$workflow")"
packages_write_count="$(grep -Ec '^[[:space:]]+packages:[[:space:]]+write$' "$workflow" || true)"
if ! grep -Fxq 'permissions:' "$workflow" ||
   ! grep -Fxq '  contents: read' "$workflow" ||
   [ "$packages_write_count" -ne 1 ] ||
   ! printf '%s\n' "$docker_job" | grep -Fxq '    permissions:' ||
   ! printf '%s\n' "$docker_job" | grep -Fxq '      contents: read' ||
   ! printf '%s\n' "$docker_job" | grep -Fxq '      packages: write'; then
  echo "ERROR: only the publication job may grant packages: write to its GITHUB_TOKEN" >&2
  exit 1
fi

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
