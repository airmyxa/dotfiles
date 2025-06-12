package di

import (
	"log"

	"github.com/example/config-provider-server/internal/config"
	"github.com/example/config-provider-server/internal/db"
	"go.uber.org/dig"
)

// BuildContainer builds the DI container with all required providers
func BuildContainer() *dig.Container {
	container := dig.New()

	// Register database provider
	if err := container.Provide(db.NewDatabaseProvider); err != nil {
		log.Fatalf("Failed to provide database provider: %v", err)
	}

	if err := container.Provide(db.ProvideDB); err != nil {
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

	return container
} 