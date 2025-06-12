package main

import (
	"testing"

	"github.com/example/config-provider-server/internal/config"
	"github.com/example/config-provider-server/internal/database"
	"github.com/example/config-provider-server/internal/server"
	"github.com/jmoiron/sqlx"
	"go.uber.org/dig"
)

// TestDIContainerSetup verifies that the DI container can be created and
// all dependencies can be resolved correctly without runtime errors.
func TestDIContainerSetup(t *testing.T) {
	// Create a test container with mock database
	container := buildTestContainer()
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

// buildTestContainer builds a DI container with mock dependencies for testing
func buildTestContainer() *dig.Container {
	container := dig.New()

	// Register mock database provider
	if err := container.Provide(database.NewMockProvider); err != nil {
		return nil
	}
	if err := container.Provide(database.ProvideMockDB); err != nil {
		return nil
	}

	// Register custom repository provider for tests
	if err := container.Provide(func(db *sqlx.DB) *config.Repository {
		// Since we're using SQLite for tests, we need to adapt the repository
		// This is a simple workaround - in a real app, you might use a repository interface
		return config.NewRepository(db)
	}); err != nil {
		return nil
	}

	// Register service provider
	if err := container.Provide(config.ProvideService); err != nil {
		return nil
	}

	// Register server providers
	if err := container.Provide(server.NewHTTP); err != nil {
		return nil
	}
	if err := container.Provide(server.NewGRPC); err != nil {
		return nil
	}

	return container
} 