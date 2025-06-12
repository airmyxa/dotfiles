# Get Configuration Metadata Endpoint
# This request retrieves metadata for a configuration
GET http://localhost:8080/configs/app-settings/metadata
HTTP/1.1 200
[Asserts]
jsonpath "$.config_name" == "app-settings"
jsonpath "$.description" exists
jsonpath "$.maintainers" isCollection 