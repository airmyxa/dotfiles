package config

import (
	"github.com/jmoiron/sqlx"
)

// ProvideRepository creates and returns a config repository
func ProvideRepository(db *sqlx.DB) RepositoryInterface {
	return NewRepository(db)
}

// ProvideService creates and returns a config service
func ProvideService(repo RepositoryInterface) *Service {
	return NewService(repo)
} 