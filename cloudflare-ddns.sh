#!/usr/bin/env bash
set -euo pipefail
echo "updating"
if [ -n "${CLOUDFLARE_A_RECORD_IDS:-}" ]; then
	addr=$(curl -sS 'https://1.1.1.1/cdn-cgi/trace' | grep 'ip=' | cut -d '=' -f 2)
	for rid in $CLOUDFLARE_A_RECORD_IDS; do
		echo "${rid} A ${addr}"
		curl -sS \
			-X PATCH "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${rid}" \
			-H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
			-H 'Content-Type: application/json' \
			--data "{\"content\": \"${addr}\"}"
	done
fi
if [ -n "${CLOUDFLARE_AAAA_RECORD_IDS:-}" ]; then
	addr=$(curl -sS 'https://[2606:4700:4700::1111]/cdn-cgi/trace' | grep 'ip=' | cut -d '=' -f 2)
	for rid in $CLOUDFLARE_AAAA_RECORD_IDS; do
		echo "${rid} AAAA ${addr}"
		curl -sS \
			-X PATCH "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/dns_records/${rid}" \
			-H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
			-H 'Content-Type: application/json' \
			--data "{\"content\": \"${addr}\"}"
	done
fi
echo "done"
