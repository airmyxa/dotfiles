# Health Check Endpoint
# This request checks if the server is running properly
GET http://localhost:8080/health
HTTP/1.1 200
[Asserts]
jsonpath "$.status" == "healthy" 