package config

import (
	"context"
	"encoding/json"
	"time"
)

type Service struct {
	repo RepositoryInterface
}

func NewService(r RepositoryInterface) *Service {
	return &Service{repo: r}
}

// ProvideService is used by the DI container
func ProvideService(repo RepositoryInterface) *Service {
	return NewService(repo)
}

func (s *Service) Create(ctx context.Context, name string, data map[string]interface{}) (*Config, error) {
	jsonData := JSONB(data)
	cfg := &Config{Name: name, Data: jsonData}
	if err := s.repo.Create(ctx, cfg); err != nil {
		return nil, err
	}
	return s.repo.Get(ctx, cfg.Name)
}

func (s *Service) CreateMetadata(ctx context.Context, configName string, description string, maintainers []string) (*ConfigMetadata, error) {
	metadata := &ConfigMetadata{
		ConfigName:  configName,
		Description: description,
		Maintainers: maintainers,
	}
	if err := s.repo.CreateMetadata(ctx, metadata); err != nil {
		return nil, err
	}
	return s.repo.GetMetadata(ctx, configName)
}

func (s *Service) Get(ctx context.Context, name string) (*Config, error) {
	return s.repo.Get(ctx, name)
}

func (s *Service) GetAtTime(ctx context.Context, name string, timestamp time.Time) (*Config, error) {
	return s.repo.GetAtTime(ctx, name, timestamp)
}

func (s *Service) GetMetadata(ctx context.Context, configName string) (*ConfigMetadata, error) {
	return s.repo.GetMetadata(ctx, configName)
}

func (s *Service) Update(ctx context.Context, name string, data map[string]interface{}) (*Config, error) {
	jsonData := JSONB(data)
	cfg := &Config{Name: name, Data: jsonData}
	if err := s.repo.Update(ctx, cfg); err != nil {
		return nil, err
	}
	return s.repo.Get(ctx, name)
}

func (s *Service) UpdateMetadata(ctx context.Context, configName string, description string, maintainers []string) (*ConfigMetadata, error) {
	metadata := &ConfigMetadata{
		ConfigName:  configName,
		Description: description,
		Maintainers: maintainers,
	}
	if err := s.repo.UpdateMetadata(ctx, metadata); err != nil {
		return nil, err
	}
	return s.repo.GetMetadata(ctx, configName)
}

func (s *Service) Delete(ctx context.Context, name string) error {
	return s.repo.Delete(ctx, name)
}

func (s *Service) UpdatedSince(ctx context.Context, since time.Time) ([]Config, error) {
	return s.repo.UpdatedSince(ctx, since)
}
