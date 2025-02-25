jq -r '.Results[].Vulnerabilities[].Severity' trivy-image-results.json | sort | uniq -c | awk '{print "{\"severity\": \""$2"\", \"count\": "$1"}"}' > trivy_image_severity_count.json
