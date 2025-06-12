package di

import (
	"log"

	"github.com/example/config-provider-server/internal/config"
	"github.com/example/config-provider-server/internal/database"
	"github.com/example/config-provider-server/internal/server"
	"go.uber.org/dig"
)

// BuildContainer builds the DI container with all required providers
func BuildContainer() *dig.Container {
	container := dig.New()

	// Register database provider
	if err := container.Provide(database.NewProvider); err != nil {
		log.Fatalf("Failed to provide database provider: %v", err)
	}

	if err := container.Provide(database.ProvideDB); err != nil {
		log.Fatalf("Failed to provide database: %v", err)
	}

	// Register repository provider
	if err := container.Provide(config.ProvideRepository); err != nil {
		log.Fatalf("Failed to provide repository: %v", err)
	}

	// Register service provider
	if err := container.Provide(config.ProvideService); err != nil {
		log.Fatalf("Failed to provide service: %v", err)
	}

	// Register server providers
	if err := container.Provide(server.NewHTTP); err != nil {
		log.Fatalf("Failed to provide HTTP server: %v", err)
	}

	if err := container.Provide(server.NewGRPC); err != nil {
		log.Fatalf("Failed to provide gRPC server: %v", err)
	}

	return container
} 