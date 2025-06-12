package database

import (
	"github.com/jmoiron/sqlx"
)

// MockProvider implements Provider interface for testing
type MockProvider struct {
	DB *sqlx.DB
}

// NewMockProvider creates a test provider with no actual database connection
func NewMockProvider() (*MockProvider, error) {
	// No actual connection is made
	return &MockProvider{DB: nil}, nil
}

// ProvideDB provides the mock database connection
func ProvideMockDB(p *MockProvider) *sqlx.DB {
	return p.DB
} 