#!/bin/bash

set -xe

DOMAINS_FILE=domains.txt
OUTPUT_FILE="hosts_generated"

echo "# Auto-generated hosts file" > "$OUTPUT_FILE"

awk '{print}' "$DOMAINS_FILE" | while read -r domain; do
    IP=$(dig +short @$DNS_SERVER "$domain" | grep -Eo '^[0-9\.]+' | head -n 1)
    if [[ -n "$IP" ]]; then
        echo "$IP $domain" >> "$OUTPUT_FILE"
        echo "Resolved: $domain -> $IP"
    else
        echo "Failed to resolve: $domain"
    fi
done

echo "Hosts file generated: $OUTPUT_FILE"

curl -X PATCH "https://api.github.com/gists/$GIST_ID" \
        -H "Authorization: token $GH_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$(jq -s --rawfile data ${OUTPUT_FILE} '{"files":{"autohosts":{"content":$data}}}' .)"

