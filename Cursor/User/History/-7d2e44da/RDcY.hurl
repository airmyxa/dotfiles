# Health Check
GET http://localhost:8080/health
HTTP/1.1 200
[Asserts]
jsonpath "$.status" == "healthy"

# Create Config
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

# Get Config
GET http://localhost:8080/configs/app-settings
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data.theme" == "dark"
jsonpath "$.data.notifications" == true
jsonpath "$.data.maxItems" == 50
jsonpath "$.updated_at" exists

# Get Config at specific time
# Replace the timestamp with a valid RFC3339 timestamp
GET http://localhost:8080/configs/app-settings?timestamp=2023-01-01T12:00:00Z
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "app-settings"
jsonpath "$.data" exists
jsonpath "$.updated_at" exists

# Update Config
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

# Get Updated Configs
# Replace the timestamp with a valid RFC3339 timestamp
GET http://localhost:8080/configs/updates?since=2023-01-01T00:00:00Z
HTTP/1.1 200
[Asserts]
jsonpath "$" isCollection
jsonpath "$[*].name" exists

# Create Metadata for Config
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

# Get Metadata
GET http://localhost:8080/configs/app-settings/metadata
HTTP/1.1 200
[Asserts]
jsonpath "$.config_name" == "app-settings"
jsonpath "$.description" == "Application configuration settings"
jsonpath "$.maintainers" isCollection

# Update Metadata
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

# Create another Config
POST http://localhost:8080/configs
Content-Type: application/json
{
    "name": "feature-flags",
    "data": {
        "newFeature": true,
        "experimentalAPI": false,
        "maxUsers": 1000
    }
}
HTTP/1.1 200
[Asserts]
jsonpath "$.name" == "feature-flags"
jsonpath "$.data.newFeature" == true
jsonpath "$.updated_at" exists

# Delete Config
DELETE http://localhost:8080/configs/feature-flags
HTTP/1.1 204 