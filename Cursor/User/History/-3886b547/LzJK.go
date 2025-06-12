package grpc

import (
	"context"
	"encoding/json"
	"time"

	cfgsvc "github.com/example/config-provider-server/internal/config"
	pb "github.com/example/config-provider-server/proto"
)

type Server struct {
	pb.UnimplementedConfigServiceServer
	svc *cfgsvc.Service
}

func NewServer(svc *cfgsvc.Service) *Server {
	return &Server{svc: svc}
}

func (s *Server) CreateConfig(ctx context.Context, req *pb.CreateConfigRequest) (*pb.Config, error) {
	// Parse JSON data
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(req.Data), &data); err != nil {
		return nil, err
	}

	c, err := s.svc.Create(ctx, req.Name, data)
	if err != nil {
		return nil, err
	}
	return toProtoConfig(c), nil
}

func (s *Server) GetConfig(ctx context.Context, req *pb.ConfigRequest) (*pb.Config, error) {
	c, err := s.svc.Get(ctx, req.Name)
	if err != nil {
		return nil, err
	}
	return toProtoConfig(c), nil
}

func (s *Server) GetConfigAtTime(ctx context.Context, req *pb.ConfigAtTimeRequest) (*pb.Config, error) {
	timestamp, err := time.Parse(time.RFC3339, req.Timestamp)
	if err != nil {
		return nil, err
	}

	c, err := s.svc.GetAtTime(ctx, req.Name, timestamp)
	if err != nil {
		return nil, err
	}
	return toProtoConfig(c), nil
}

func (s *Server) UpdateConfig(ctx context.Context, req *pb.UpdateConfigRequest) (*pb.Config, error) {
	// Parse JSON data
	var data map[string]interface{}
	if err := json.Unmarshal([]byte(req.Data), &data); err != nil {
		return nil, err
	}

	c, err := s.svc.Update(ctx, req.Name, data)
	if err != nil {
		return nil, err
	}
	return toProtoConfig(c), nil
}

func (s *Server) DeleteConfig(ctx context.Context, req *pb.ConfigRequest) (*pb.Config, error) {
	c, err := s.svc.Get(ctx, req.Name)
	if err != nil {
		return nil, err
	}
	if err := s.svc.Delete(ctx, req.Name); err != nil {
		return nil, err
	}
	return toProtoConfig(c), nil
}

func (s *Server) GetUpdatedConfigs(ctx context.Context, req *pb.ConfigsUpdatedRequest) (*pb.ConfigsResponse, error) {
	t, err := time.Parse(time.RFC3339, req.Since)
	if err != nil {
		return nil, err
	}
	cfgs, err := s.svc.UpdatedSince(ctx, t)
	if err != nil {
		return nil, err
	}
	resp := &pb.ConfigsResponse{}
	for _, c := range cfgs {
		resp.Configs = append(resp.Configs, toProtoConfig(&c))
	}
	return resp, nil
}

func (s *Server) CreateMetadata(ctx context.Context, req *pb.CreateMetadataRequest) (*pb.ConfigMetadata, error) {
	m, err := s.svc.CreateMetadata(ctx, req.ConfigName, req.Description, req.Maintainers)
	if err != nil {
		return nil, err
	}
	return toProtoMetadata(m), nil
}

func (s *Server) GetMetadata(ctx context.Context, req *pb.ConfigRequest) (*pb.ConfigMetadata, error) {
	m, err := s.svc.GetMetadata(ctx, req.Name)
	if err != nil {
		return nil, err
	}
	return toProtoMetadata(m), nil
}

func (s *Server) UpdateMetadata(ctx context.Context, req *pb.UpdateMetadataRequest) (*pb.ConfigMetadata, error) {
	m, err := s.svc.UpdateMetadata(ctx, req.ConfigName, req.Description, req.Maintainers)
	if err != nil {
		return nil, err
	}
	return toProtoMetadata(m), nil
}

func toProtoConfig(c *cfgsvc.Config) *pb.Config {
	// Convert JSONB to string for transfer
	dataBytes, _ := json.Marshal(c.Data)

	return &pb.Config{
		Name:      c.Name,
		Data:      string(dataBytes),
		UpdatedAt: c.UpdatedAt.Format(time.RFC3339),
	}
}

func toProtoMetadata(m *cfgsvc.ConfigMetadata) *pb.ConfigMetadata {
	return &pb.ConfigMetadata{
		ConfigName:  m.ConfigName,
		Description: m.Description,
		Maintainers: m.Maintainers,
	}
}
