package database

import (
	"github.com/jmoiron/sqlx"
	_ "github.com/mattn/go-sqlite3"
)

// MockProvider implements Provider interface for testing
type MockProvider struct {
	DB *sqlx.DB
}

// NewMockProvider creates a test provider with an in-memory SQLite database
func NewMockProvider() (*MockProvider, error) {
	// Use in-memory SQLite for testing
	db, err := sqlx.Open("sqlite3", ":memory:")
	if err != nil {
		return nil, err
	}

	// Create a simple schema for testing
	_, err = db.Exec(`CREATE TABLE IF NOT EXISTS configs (
		id TEXT PRIMARY KEY,
		data TEXT NOT NULL,
		updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	)`)
	if err != nil {
		return nil, err
	}

	return &MockProvider{DB: db}, nil
}

// ProvideDB provides the mock database connection
func ProvideMockDB(p *MockProvider) *sqlx.DB {
	return p.DB
} 