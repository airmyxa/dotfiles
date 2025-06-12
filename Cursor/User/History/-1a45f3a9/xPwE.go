package config

import (
	"context"
	"github.com/google/uuid"
	"time"
)

type Service struct {
	repo RepositoryInterface
}

func NewService(r RepositoryInterface) *Service {
	return &Service{repo: r}
}

func (s *Service) Create(ctx context.Context, data string) (*Config, error) {
	cfg := &Config{ID: uuid.NewString(), Data: data}
	if err := s.repo.Create(ctx, cfg); err != nil {
		return nil, err
	}
	return s.repo.Get(ctx, cfg.ID)
}

func (s *Service) Get(ctx context.Context, id string) (*Config, error) {
	return s.repo.Get(ctx, id)
}

func (s *Service) Update(ctx context.Context, id, data string) (*Config, error) {
	cfg := &Config{ID: id, Data: data}
	if err := s.repo.Update(ctx, cfg); err != nil {
		return nil, err
	}
	return s.repo.Get(ctx, id)
}

func (s *Service) Delete(ctx context.Context, id string) error {
	return s.repo.Delete(ctx, id)
}

func (s *Service) UpdatedSince(ctx context.Context, since time.Time) ([]Config, error) {
	return s.repo.UpdatedSince(ctx, since)
}
