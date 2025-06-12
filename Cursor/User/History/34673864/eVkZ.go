package config

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/example/config-provider-server/internal/database"
	"github.com/jmoiron/sqlx"
)

func TestMain(m *testing.M) {
	// Set up test database using SQLite (no Docker dependency)
	provider, err := database.NewSimpleTestProvider()
	if err != nil {
		panic(err)
	}

	// Set the global provider for tests
	testDB = provider

	// Run tests
	code := m.Run()

	// Clean up
	if err := provider.Close(); err != nil {
		panic(err)
	}

	os.Exit(code)
}

var testDB interface {
	GetDB() *sqlx.DB
	Close() error
}

func setupTest(t *testing.T) (*Service, *Repository, context.Context) {
	db := testDB.GetDB()

	// Clear database between tests
	_, err := db.Exec(`
		DELETE FROM config_metadata;
		DELETE FROM configs;
	`)
	if err != nil {
		t.Fatalf("Failed to clear database: %v", err)
	}

	repo := NewRepository(db)
	service := NewService(repo)
	ctx := context.Background()

	return service, repo, ctx
}

func TestServiceCreateAndGet(t *testing.T) {
	service, _, ctx := setupTest(t)

	// Create a config
	name := "test-config"
	data := map[string]interface{}{
		"key1": "value1",
		"key2": 42,
		"nested": map[string]interface{}{
			"nestedKey": "nestedValue",
		},
	}

	cfg, err := service.Create(ctx, name, data)
	if err != nil {
		t.Fatalf("Failed to create config: %v", err)
	}

	if cfg.Name != name {
		t.Errorf("Expected name to be %q, got %q", name, cfg.Name)
	}

	// Get the config
	fetched, err := service.Get(ctx, name)
	if err != nil {
		t.Fatalf("Failed to get config: %v", err)
	}

	if fetched.Name != name {
		t.Errorf("Expected name %q, got %q", name, fetched.Name)
	}

	// Check data
	if fetchedValue, ok := fetched.Data["key1"].(string); !ok || fetchedValue != "value1" {
		t.Errorf("Expected data.key1 to be 'value1', got %v", fetched.Data["key1"])
	}

	if fetchedValue, ok := fetched.Data["key2"].(float64); !ok || int(fetchedValue) != 42 {
		t.Errorf("Expected data.key2 to be 42, got %v", fetched.Data["key2"])
	}
}

func TestConfigMetadata(t *testing.T) {
	service, _, ctx := setupTest(t)

	// Create a config first
	name := "config-with-metadata"
	data := map[string]interface{}{"key": "value"}

	_, err := service.Create(ctx, name, data)
	if err != nil {
		t.Fatalf("Failed to create config: %v", err)
	}

	// Create metadata
	description := "Test config description"
	maintainers := []string{"user1@example.com", "user2@example.com"}

	metadata, err := service.CreateMetadata(ctx, name, description, maintainers)
	if err != nil {
		t.Fatalf("Failed to create metadata: %v", err)
	}

	if metadata.ConfigName != name {
		t.Errorf("Expected config_name to be %q, got %q", name, metadata.ConfigName)
	}

	if metadata.Description != description {
		t.Errorf("Expected description to be %q, got %q", description, metadata.Description)
	}

	if len(metadata.Maintainers) != len(maintainers) {
		t.Errorf("Expected %d maintainers, got %d", len(maintainers), len(metadata.Maintainers))
	}

	// Get metadata
	fetched, err := service.GetMetadata(ctx, name)
	if err != nil {
		t.Fatalf("Failed to get metadata: %v", err)
	}

	if fetched.Description != description {
		t.Errorf("Expected description to be %q, got %q", description, fetched.Description)
	}
}

func TestConfigVersioning(t *testing.T) {
	service, _, ctx := setupTest(t)

	// Create a config
	name := "versioned-config"
	initialData := map[string]interface{}{"version": 1, "value": "initial"}

	initial, err := service.Create(ctx, name, initialData)
	if err != nil {
		t.Fatalf("Failed to create initial config: %v", err)
	}

	initialTimestamp := initial.UpdatedAt

	// Wait a full second to ensure the SQLite timestamp changes
	time.Sleep(1 * time.Second)

	// Update the config
	updatedData := map[string]interface{}{"version": 2, "value": "updated"}
	_, err = service.Update(ctx, name, updatedData)
	if err != nil {
		t.Fatalf("Failed to update config: %v", err)
	}

	// Get the original version by timestamp
	originalVersion, err := service.GetAtTime(ctx, name, initialTimestamp.Add(time.Millisecond))
	if err != nil {
		t.Fatalf("Failed to get original version: %v", err)
	}

	// Verify we got the correct version
	if version, ok := originalVersion.Data["version"].(float64); !ok || int(version) != 1 {
		t.Errorf("Expected version 1, got %v (%T)", originalVersion.Data["version"], originalVersion.Data["version"])
	}

	// Get the current version
	currentVersion, err := service.Get(ctx, name)
	if err != nil {
		t.Fatalf("Failed to get current version: %v", err)
	}

	// Verify we got the updated version
	if version, ok := currentVersion.Data["version"].(float64); !ok || int(version) != 2 {
		t.Errorf("Expected version 2, got %v (%T)", currentVersion.Data["version"], currentVersion.Data["version"])
	}
}
