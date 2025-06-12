package main

import (
	"testing"

	"github.com/example/config-provider-server/internal/core/di"
	"github.com/example/config-provider-server/internal/server"
)

// TestDIContainerSetup verifies that the DI container can be created and
// all dependencies can be resolved correctly without runtime errors.
func TestDIContainerSetup(t *testing.T) {
	// Skip if running real tests that require a database
	t.Skip("This test requires a database. Run manually with -tags=integration")

	// Create a container
	container := di.BuildContainer()
	if container == nil {
		t.Fatal("Failed to build container")
	}

	// Verify we can resolve HTTP server
	err := container.Invoke(func(httpServer *server.HTTP) {
		if httpServer == nil {
			t.Fatal("Failed to resolve HTTP server")
		}
	})
	if err != nil {
		t.Fatalf("Failed to invoke HTTP server: %v", err)
	}

	// Verify we can resolve gRPC server
	err = container.Invoke(func(grpcServer *server.GRPC) {
		if grpcServer == nil {
			t.Fatal("Failed to resolve gRPC server")
		}
	})
	if err != nil {
		t.Fatalf("Failed to invoke gRPC server: %v", err)
	}
} 