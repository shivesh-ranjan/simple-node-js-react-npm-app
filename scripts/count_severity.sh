#!/bin/bash
if [ -z "$1" ]; then
	echo "Usage: $0 <json_file>"
	exit 1
fi
json_file="$1"
critical_count="$2"
high_count="$3"
if [ ! -f "$json_file" ]; then
	echo "File not found: $json_file"
	exit 1
fi
while IFS= read -r line; do
	if echo "$line" | jq -e ".severity == 'CRITICAL' and .count > $critical_count" > /dev/null || echo "$line" | jq -e ".severity == 'HIGH' and .count > $high_count" > /dev/null; then
		echo "Found more CRITICAL or HIGH severity vulnerabilities than allowed in policy"
		exit 1
	fi
done < "$json_file"
exit 0
