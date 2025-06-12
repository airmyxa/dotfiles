package main

import (
	"log"

	"github.com/example/config-provider-server/internal/di"
)

func main() {
	container := di.BuildContainer()

	// Start HTTP server in a goroutine
	if err := container.Invoke(func(httpServer *di.HTTPServer) {
		go httpServer.Start()
	}); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}

	// Start gRPC server (blocking call)
	if err := container.Invoke(func(grpcServer *di.GRPCServer) {
		grpcServer.Start()
	}); err != nil {
		log.Fatalf("Failed to start gRPC server: %v", err)
	}
}
