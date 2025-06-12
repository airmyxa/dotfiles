package di

import (
	"log"
	"net"
	"net/http"

	pb "github.com/example/config-provider-server/api/grpc"
	apihttp "github.com/example/config-provider-server/api/http"
	"github.com/example/config-provider-server/internal/config"
	grpcserver "github.com/example/config-provider-server/internal/grpc"
	"google.golang.org/grpc"
)

// HTTPServer provides an HTTP server with dependencies
type HTTPServer struct {
	Service *config.Service
}

// NewHTTPServer creates a new HTTP server with injected dependencies
func NewHTTPServer(service *config.Service) *HTTPServer {
	return &HTTPServer{Service: service}
}

// Start starts the HTTP server
func (s *HTTPServer) Start() {
	h := apihttp.NewHandler(s.Service)
	log.Println("HTTP server on :8080")
	log.Fatal(http.ListenAndServe(":8080", h))
}

// GRPCServer provides a gRPC server with dependencies
type GRPCServer struct {
	Service *config.Service
}

// NewGRPCServer creates a new gRPC server with injected dependencies
func NewGRPCServer(service *config.Service) *GRPCServer {
	return &GRPCServer{Service: service}
}

// Start starts the gRPC server
func (s *GRPCServer) Start() {
	lis, err := net.Listen("tcp", ":9090")
	if err != nil {
		log.Fatalf("grpc listen: %v", err)
	}
	server := grpc.NewServer()
	pb.RegisterConfigServiceServer(server, grpcserver.NewServer(s.Service))
	log.Println("gRPC server on :9090")
	log.Fatal(server.Serve(lis))
} 