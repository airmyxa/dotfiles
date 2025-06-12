# Get Configuration Endpoint
# This request retrieves a configuration by its name
GET http://localhost:8080/configs/app-settings
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data" exists
jsonpath "$.updated_at" exists 