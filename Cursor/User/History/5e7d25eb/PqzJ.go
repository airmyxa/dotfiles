package db

import (
	"github.com/jmoiron/sqlx"
	"os"

	_ "github.com/jackc/pgx/v5/stdlib"
)

// DatabaseProvider provides a database connection for the DI container
type DatabaseProvider struct {
	DB *sqlx.DB
}

// NewDatabaseProvider creates a new database connection provider
func NewDatabaseProvider() (*DatabaseProvider, error) {
	dsn := os.Getenv("DATABASE_URL")
	db, err := sqlx.Open("pgx", dsn)
	if err != nil {
		return nil, err
	}
	return &DatabaseProvider{DB: db}, nil
}

// ProvideDB provides the database connection
func ProvideDB(p *DatabaseProvider) *sqlx.DB {
	return p.DB
} 