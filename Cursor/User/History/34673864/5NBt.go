package config

import (
	"context"
	"testing"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

// setupTestDB creates an in-memory SQLite database for testing
func setupTestDB(t *testing.T) *sqlx.DB {
	db, err := sqlx.Open("sqlite3", ":memory:")
	if err != nil {
		t.Fatalf("Failed to open in-memory database: %v", err)
	}

	// Create schema
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS configs (
		id TEXT PRIMARY KEY,
		data TEXT NOT NULL,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	)`)
	if err != nil {
		t.Fatalf("Failed to create schema: %v", err)
	}

	return db
}

func TestServiceCreateAndGet(t *testing.T) {
	db := setupTestDB(t)
	defer db.Close()

	repo := NewRepository(db)
	service := NewService(repo)

	// Create a config
	data := "test-data"
	ctx := context.Background()
	
	cfg, err := service.Create(ctx, data)
	if err != nil {
		t.Fatalf("Failed to create config: %v", err)
	}
	
	if cfg.Data != data {
		t.Errorf("Expected data to be %q, got %q", data, cfg.Data)
	}
	
	if cfg.ID == "" {
		t.Error("Expected non-empty ID")
	}
	
	// Get the config
	fetched, err := service.Get(ctx, cfg.ID)
	if err != nil {
		t.Fatalf("Failed to get config: %v", err)
	}
	
	if fetched.ID != cfg.ID {
		t.Errorf("Expected ID %q, got %q", cfg.ID, fetched.ID)
	}
	
	if fetched.Data != data {
		t.Errorf("Expected data %q, got %q", data, fetched.Data)
	}
} 