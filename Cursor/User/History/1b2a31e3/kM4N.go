package server

import (
	"log"
	"net"

	pb "github.com/example/config-provider-server/internal/api/grpc"
	"github.com/example/config-provider-server/internal/config"
	grpcserver "github.com/example/config-provider-server/internal/grpc"
	"google.golang.org/grpc"
)

// GRPC provides a gRPC server with dependencies
type GRPC struct {
	Service *config.Service
}

// NewGRPC creates a new gRPC server with injected dependencies
func NewGRPC(service *config.Service) *GRPC {
	return &GRPC{Service: service}
}

// Start starts the gRPC server
func (s *GRPC) Start() {
	lis, err := net.Listen("tcp", ":9090")
	if err != nil {
		log.Fatalf("grpc listen: %v", err)
	}
	server := grpc.NewServer()
	pb.RegisterConfigServiceServer(server, grpcserver.NewServer(s.Service))
	log.Println("gRPC server on :9090")
	log.Fatal(server.Serve(lis))
}
