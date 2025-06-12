# Create Configuration Endpoint
# This request creates a new configuration with the specified name and data
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