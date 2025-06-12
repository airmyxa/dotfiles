# Complete API Test Suite
# This file contains all API requests in a logical order for testing

# 1. Health Check
GET http://localhost:8080/health
HTTP/1.1 200
[Asserts]
jsonpath "$.status" == "healthy"

# 2. Create Configuration
POST http://localhost:8080/configs
Content-Type: application/json
{
    "name": "app-settings",
    "data": {
        "theme": "dark",
        "notifications": true,
        "maxItems": 50
    }
}

HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data.theme" == "dark"
jsonpath "$.data.notifications" == true
jsonpath "$.data.maxItems" == 50
jsonpath "$.updated_at" exists

# 3. Get Configuration
GET http://localhost:8080/configs/app-settings
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data.theme" == "dark"
jsonpath "$.data.notifications" == true
jsonpath "$.data.maxItems" == 50
jsonpath "$.updated_at" exists

# 4. Create Configuration Metadata
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

# 5. Get Configuration Metadata
GET http://localhost:8080/configs/app-settings/metadata
HTTP/1.1 200
[Asserts]
jsonpath "$.config_name" == "app-settings"
jsonpath "$.description" == "Application configuration settings"
jsonpath "$.maintainers" isCollection

# 6. Update Configuration
PUT http://localhost:8080/configs/app-settings
Content-Type: application/json
{
    "data": {
        "theme": "light",
        "notifications": false,
        "maxItems": 100
    }
}

HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data.theme" == "light"
jsonpath "$.data.notifications" == false
jsonpath "$.data.maxItems" == 100
jsonpath "$.updated_at" exists

# 7. Get Updated Configurations
# The timestamp should be before the create/update operations above
GET http://localhost:8080/configs/updates?since=2023-01-01T00:00:00Z
HTTP/1.1 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[*].name" exists

# 8. Update Configuration Metadata
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

# 9. Create Second Configuration for Delete Test
POST http://localhost:8080/configs
Content-Type: application/json
{
    "name": "temp-config",
    "data": {
        "temporary": true,
        "value": "delete-me"
    }
}

HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "temp-config"
jsonpath "$.data.temporary" == true
jsonpath "$.updated_at" exists

# 10. Delete Configuration
DELETE http://localhost:8080/configs/temp-config
HTTP/1.1 204 