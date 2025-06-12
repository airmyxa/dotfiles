package config

import (
	"context"
	"time"

	"github.com/jmoiron/sqlx"
)

// RepositoryInterface defines the operations for config data storage
type RepositoryInterface interface {
	Create(ctx context.Context, cfg *Config) error
	Get(ctx context.Context, id string) (*Config, error)
	Update(ctx context.Context, cfg *Config) error
	Delete(ctx context.Context, id string) error
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
	query := `INSERT INTO configs (id, data, updated_at) VALUES ($1, $2, NOW())`
	_, err := r.db.ExecContext(ctx, query, cfg.ID, cfg.Data)
	return err
}

func (r *Repository) Get(ctx context.Context, id string) (*Config, error) {
	var c Config
	err := r.db.GetContext(ctx, &c, `SELECT id, data, updated_at FROM configs WHERE id=$1`, id)
	if err != nil {
		return nil, err
	}
	return &c, nil
}

func (r *Repository) Update(ctx context.Context, cfg *Config) error {
	query := `UPDATE configs SET data=$1, updated_at=NOW() WHERE id=$2`
	_, err := r.db.ExecContext(ctx, query, cfg.Data, cfg.ID)
	return err
}

func (r *Repository) Delete(ctx context.Context, id string) error {
	_, err := r.db.ExecContext(ctx, `DELETE FROM configs WHERE id=$1`, id)
	return err
}

func (r *Repository) UpdatedSince(ctx context.Context, since time.Time) ([]Config, error) {
	var cfgs []Config
	err := r.db.SelectContext(ctx, &cfgs, `SELECT id, data, updated_at FROM configs WHERE updated_at > $1`, since)
	return cfgs, err
}
