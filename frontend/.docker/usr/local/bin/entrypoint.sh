#!/bin/sh
set -x

for ENTRYPOINT in $(find /etc/docker-entrypoint.d/ -name '*.sh' | sort); do
    source "${ENTRYPOINT}"
done
