#!/bin/bash
# certbot manual-auth-hook for CI: publish the TXT record on
# pebble-challtestsrv's management API.
set -euo pipefail
curl -s -X POST "http://challtestsrv:8055/set-txt" \
  -d "{\"host\": \"_acme-challenge.${CERTBOT_DOMAIN}.\", \"value\": \"${CERTBOT_VALIDATION}\"}"
