# Update Configuration Metadata Endpoint
# This request updates metadata for an existing configuration
PUT http://localhost:8080/configs/app-settings/metadata
Content-Type: application/json
{
    "description": "Updated application settings",
    "maintainers": ["charlie@example.com"]
}

HTTP/1.1 200
[Asserts]
jsonpath "$.config_name" == "app-settings"
jsonpath "$.description" == "Updated application settings"
jsonpath "$.maintainers" isCollection
jsonpath "$.maintainers[0]" == "charlie@example.com" 