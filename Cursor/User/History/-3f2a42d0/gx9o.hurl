# Get Updated Configurations Endpoint
# This request retrieves all configurations updated since the specified time
# Replace the timestamp with a valid RFC3339 timestamp
GET http://localhost:8080/configs/updates?since=2023-01-01T00:00:00Z
HTTP/1.1 200
[Asserts]
jsonpath "$" isCollection 