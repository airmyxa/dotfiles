package database

import (
	"context"

	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

// SimpleTestProvider provides an in-memory SQLite database for testing
type SimpleTestProvider struct {
	DB *sqlx.DB
}

// NewSimpleTestProvider creates a new in-memory SQLite database for testing
func NewSimpleTestProvider() (*SimpleTestProvider, error) {
	// Create an in-memory SQLite database
	db, err := sqlx.Connect("sqlite3", ":memory:")
	if err != nil {
		return nil, err
	}

	// Create configs table
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS configs (
			name TEXT PRIMARY KEY,
			data TEXT NOT NULL, -- SQLite doesn't have JSONB, so we'll use TEXT
			updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)
	`)
	if err != nil {
		return nil, err
	}

	// Create index
	_, err = db.Exec(`
		CREATE INDEX IF NOT EXISTS idx_configs_updated_at ON configs(updated_at)
	`)
	if err != nil {
		return nil, err
	}

	// Create metadata table
	_, err = db.Exec(`
		CREATE TABLE IF NOT EXISTS config_metadata (
			config_name TEXT PRIMARY KEY REFERENCES configs(name) ON DELETE CASCADE,
			description TEXT,
			maintainers TEXT DEFAULT '[]' -- Store JSON as TEXT
		)
	`)
	if err != nil {
		return nil, err
	}

	return &SimpleTestProvider{DB: db}, nil
}

// GetDB returns the database connection
func (p *SimpleTestProvider) GetDB() *sqlx.DB {
	return p.DB
}

// Close closes the database connection
func (p *SimpleTestProvider) Close() error {
	return p.DB.Close()
}

// ResetDatabase clears all data from the database
func (p *SimpleTestProvider) ResetDatabase(ctx context.Context) error {
	_, err := p.DB.ExecContext(ctx, `
		DELETE FROM config_metadata;
		DELETE FROM configs;
	`)
	return err
}
