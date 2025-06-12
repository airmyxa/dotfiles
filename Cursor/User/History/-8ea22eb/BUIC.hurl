# Create Configuration Metadata Endpoint
# This request creates metadata for an existing configuration
POST http://localhost:8080/configs/app-settings/metadata
Content-Type: application/json
{
    "description": "Application configuration settings",
    "maintainers": ["alice@example.com", "bob@example.com"]
}

HTTP/1.1 200
[Asserts]
jsonpath "$.config_name" == "app-settings"
jsonpath "$.description" == "Application configuration settings"
jsonpath "$.maintainers" isCollection
jsonpath "$.maintainers[0]" == "alice@example.com"
jsonpath "$.maintainers[1]" == "bob@example.com" 