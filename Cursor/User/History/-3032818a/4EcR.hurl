# Get Configuration at Specific Time Endpoint
# This request retrieves a configuration as it existed at a specific time
# Replace the timestamp with a valid RFC3339 timestamp
GET http://localhost:8080/configs/app-settings?timestamp=2023-01-01T12:00:00Z
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data" exists
jsonpath "$.updated_at" exists 