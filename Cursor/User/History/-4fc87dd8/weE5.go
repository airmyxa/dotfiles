package database

import (
	"github.com/jmoiron/sqlx"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
)

// Provider provides a database connection for the DI container
type Provider struct {
	DB *sqlx.DB
}

// NewProvider creates a new database connection provider
func NewProvider() (*Provider, error) {
	dsn := os.Getenv("DATABASE_URL")
	db, err := sqlx.Open("pgx", dsn)
	if err != nil {
		return nil, err
	}
	return &Provider{DB: db}, nil
}

// ProvideDB provides the database connection
func ProvideDB(p *Provider) *sqlx.DB {
	return p.DB
} 