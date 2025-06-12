# Config Provider Server

A service for storing and retrieving configuration data.

## Features

- Store and retrieve configuration data with versioning
- Access historical configuration versions by timestamp
- Store metadata for configurations (description, maintainers)
- Both HTTP and gRPC APIs
- PostgreSQL storage backend

## Running with Docker Compose

```bash
# Generate self-signed SSL certificates for development
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/config-service.key -out ssl/config-service.crt \
  -subj "/CN=config-service.example.com"

# Start the services
docker-compose up -d
```

## Using Nginx as Reverse Proxy

This project includes an Nginx configuration that provides several benefits:

### Load Balancing
Nginx can distribute incoming requests across multiple service instances, improving availability and scalability. The docker-compose file can be extended to run multiple instances of the config service.

### SSL Termination
Nginx handles HTTPS traffic and forwards it as unencrypted HTTP to the backend services, reducing the CPU load on application servers.

### Caching
Nginx caches responses to GET requests, significantly reducing database load for frequently accessed configurations. The caching system is aware of timestamp-based version access, ensuring that the correct version is served.

### Rate Limiting
Nginx implements rate limiting to protect the service from abuse and denial-of-service attacks.

### Access Control
Nginx can provide additional layers of security through IP restrictions, authentication, and authorization.

### URL Routing
Nginx routes HTTP API requests to the HTTP server and gRPC requests to the gRPC server through a single entry point.

## API Usage

### HTTP API

```bash
# Create a config
curl -X POST -H "Content-Type: application/json" \
  -d '{"name":"app-config", "data":{"feature1":true, "timeout":30}}' \
  https://config-service.example.com/api/configs

# Get a config
curl https://config-service.example.com/api/configs/app-config

# Get a config at a specific time
curl https://config-service.example.com/api/configs/app-config?timestamp=2023-06-01T12:00:00Z

# Update a config
curl -X PUT -H "Content-Type: application/json" \
  -d '{"data":{"feature1":false, "timeout":60}}' \
  https://config-service.example.com/api/configs/app-config

# Add config metadata
curl -X POST -H "Content-Type: application/json" \
  -d '{"description":"Main application config", "maintainers":["user1@example.com","user2@example.com"]}' \
  https://config-service.example.com/api/configs/app-config/metadata
```

### gRPC API

The gRPC API provides the same functionality as the HTTP API through the protobuf interface defined in `proto/config.proto`.
