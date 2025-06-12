package config

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

// RepositoryInterface defines the operations for config data storage
type RepositoryInterface interface {
	Create(ctx context.Context, cfg *Config) error
	CreateMetadata(ctx context.Context, metadata *ConfigMetadata) error
	Get(ctx context.Context, name string) (*Config, error)
	GetAtTime(ctx context.Context, name string, timestamp time.Time) (*Config, error)
	GetMetadata(ctx context.Context, configName string) (*ConfigMetadata, error)
	Update(ctx context.Context, cfg *Config) error
	UpdateMetadata(ctx context.Context, metadata *ConfigMetadata) error
	Delete(ctx context.Context, name string) error
	UpdatedSince(ctx context.Context, since time.Time) ([]Config, error)
}

// Repository is the PostgreSQL implementation of RepositoryInterface
type Repository struct {
	db *sqlx.DB
}

func NewRepository(db *sqlx.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) Create(ctx context.Context, cfg *Config) error {
	query := `INSERT INTO configs (name, data, updated_at) VALUES ($1, $2, NOW())`
	_, err := r.db.ExecContext(ctx, query, cfg.Name, cfg.Data)
	return err
}

func (r *Repository) CreateMetadata(ctx context.Context, metadata *ConfigMetadata) error {
	query := `INSERT INTO config_metadata (config_name, description, maintainers) VALUES ($1, $2, $3)`
	_, err := r.db.ExecContext(ctx, query, metadata.ConfigName, metadata.Description, metadata.Maintainers)
	return err
}

func (r *Repository) Get(ctx context.Context, name string) (*Config, error) {
	var c Config
	err := r.db.GetContext(ctx, &c, `SELECT name, data, updated_at FROM configs WHERE name=$1`, name)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *Repository) GetAtTime(ctx context.Context, name string, timestamp time.Time) (*Config, error) {
	var c Config
	err := r.db.GetContext(ctx, &c, `
		SELECT name, data, updated_at 
		FROM configs 
		WHERE name=$1 AND updated_at <= $2 
		ORDER BY updated_at DESC 
		LIMIT 1`, name, timestamp)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *Repository) GetMetadata(ctx context.Context, configName string) (*ConfigMetadata, error) {
	var m ConfigMetadata
	err := r.db.GetContext(ctx, &m, `SELECT config_name, description, maintainers FROM config_metadata WHERE config_name=$1`, configName)
	if err != nil {
		return nil, err
	}
	return &m, nil
}

func (r *Repository) Update(ctx context.Context, cfg *Config) error {
	query := `UPDATE configs SET data=$1, updated_at=NOW() WHERE name=$2`
	_, err := r.db.ExecContext(ctx, query, cfg.Data, cfg.Name)
	return err
}

func (r *Repository) UpdateMetadata(ctx context.Context, metadata *ConfigMetadata) error {
	query := `UPDATE config_metadata SET description=$1, maintainers=$2 WHERE config_name=$3`
	_, err := r.db.ExecContext(ctx, query, metadata.Description, metadata.Maintainers, metadata.ConfigName)
	return err
}

func (r *Repository) Delete(ctx context.Context, name string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM configs WHERE name=$1`, name)
	return err
}

func (r *Repository) UpdatedSince(ctx context.Context, since time.Time) ([]Config, error) {
	var cfgs []Config
	err := r.db.SelectContext(ctx, &cfgs, `SELECT name, data, updated_at FROM configs WHERE updated_at > $1`, since)
	return cfgs, err
}
