jq -r '.Results[].Vulnerabilities[].Severity' trivy-sca-results.json | sort | uniq -c | awk '{print "{\"severity\": \""$2"\", \"count\": "$1"}"}' > trivy_sca_severity_count.json
