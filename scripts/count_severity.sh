#!/bin/bash
if [ -z "$1" ]; then
	echo "Usage: $0 <json_file>"
	exit 1
fi
json_file="$1"
if [ ! -f "$json_file" ]; then
	echo "File not found: $json_file"
	exit 1
fi
while IFS= read -r line; do
	if echo "$line" | jq -e '.severity == "CRITICAL" and .count > 0' > /dev/null || echo "$line" | jq -e '.severity == "HIGH" and .count > 0' > /dev/null; then
		echo "Found CRITICAL or HIGH severity vulnerability..."
		exit 1
	fi
done < "$json_file"
exit 0
