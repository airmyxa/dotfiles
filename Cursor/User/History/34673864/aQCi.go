package config

import (
	"context"
	"testing"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

// SQLiteRepository is a test-specific repository implementation for SQLite
type SQLiteRepository struct {
	db *sqlx.DB
}

// Ensure SQLiteRepository implements RepositoryInterface
var _ RepositoryInterface = (*SQLiteRepository)(nil)

func NewSQLiteRepository(db *sqlx.DB) *SQLiteRepository {
	return &SQLiteRepository{db: db}
}

func (r *SQLiteRepository) Create(ctx context.Context, cfg *Config) error {
	query := `INSERT INTO configs (id, data, updated_at) VALUES (?, ?, datetime('now'))`
	_, err := r.db.ExecContext(ctx, query, cfg.ID, cfg.Data)
	return err
}

func (r *SQLiteRepository) Get(ctx context.Context, id string) (*Config, error) {
	var c Config
	err := r.db.GetContext(ctx, &c, `SELECT id, data, updated_at FROM configs WHERE id=?`, id)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *SQLiteRepository) Update(ctx context.Context, cfg *Config) error {
	query := `UPDATE configs SET data=?, updated_at=datetime('now') WHERE id=?`
	_, err := r.db.ExecContext(ctx, query, cfg.Data, cfg.ID)
	return err
}

func (r *SQLiteRepository) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM configs WHERE id=?`, id)
	return err
}

func (r *SQLiteRepository) UpdatedSince(ctx context.Context, since time.Time) ([]Config, error) {
	var cfgs []Config
	err := r.db.SelectContext(ctx, &cfgs, `SELECT id, data, updated_at FROM configs WHERE updated_at > ?`, since)
	return cfgs, err
}

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

	repo := NewSQLiteRepository(db)
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