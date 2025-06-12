# Config Provider Server

A simple configuration server with HTTP and gRPC APIs.

## Features

- REST API on port 8080
- gRPC API on port 9090
- PostgreSQL database for persistence
- Dependency injection using `uber/dig`

## Running with Docker Compose

The easiest way to run the application is with Docker Compose:

```bash
# Build and start the services
docker-compose up -d

# Check the logs
docker-compose logs -f

# Stop the services
docker-compose down
```

This will start:
- PostgreSQL database on port 5432
- Config Provider server with HTTP API on port 8080 and gRPC on port 9090

## Building Manually

```bash
docker build -t config-server .
```

## Running Manually

PostgreSQL connection is configured via `DATABASE_URL` environment variable.

```bash
docker run -e DATABASE_URL=postgres://user:pass@host/dbname?sslmode=disable -p 8080:8080 -p 9090:9090 config-server
```

## API Usage

### HTTP API

```bash
# Create a config
curl -X POST -H "Content-Type: application/json" -d '{"data":"example data"}' http://localhost:8080/configs

# Get a config
curl http://localhost:8080/configs/{id}

# Update a config
curl -X PUT -H "Content-Type: application/json" -d '{"data":"updated data"}' http://localhost:8080/configs/{id}

# Delete a config
curl -X DELETE http://localhost:8080/configs/{id}

# Get configs updated since a timestamp
curl http://localhost:8080/configs/updates?since=2023-01-01T00:00:00Z
```

### Health Check

```bash
curl http://localhost:8080/health
```
