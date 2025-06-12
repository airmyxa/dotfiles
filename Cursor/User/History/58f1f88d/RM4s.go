package database

import (
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/jmoiron/sqlx"
)

// MockProvider implements Provider interface for testing
type MockProvider struct {
	testProvider *TestPostgresProvider
	DB           *sqlx.DB
}

// NewMockProvider creates a test provider with a PostgreSQL database
func NewMockProvider() (*MockProvider, error) {
	testProvider, err := NewTestPostgresProvider([]string{"../../postgres/migrations/V1_init.sql"})
	if err != nil {
		return nil, err
	}

	return &MockProvider{
		testProvider: testProvider,
		DB:           testProvider.DB,
	}, nil
}

// ProvideDB provides the mock database connection
func ProvideMockDB(p *MockProvider) *sqlx.DB {
	return p.DB
}

// Close closes the database connection and stops the Postgres container
func (p *MockProvider) Close() error {
	if p.testProvider != nil {
		return p.testProvider.Close()
	}
	return nil
}
