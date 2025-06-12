# Update Configuration Endpoint
# This request updates an existing configuration
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