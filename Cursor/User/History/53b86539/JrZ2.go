package server

import (
	"log"
	"net/http"

	apihttp "github.com/example/config-provider-server/internal/api/http"
	"github.com/example/config-provider-server/internal/config"
)

// HTTP provides an HTTP server with dependencies
type HTTP struct {
	Service *config.Service
}

// NewHTTP creates a new HTTP server with injected dependencies
func NewHTTP(service *config.Service) *HTTP {
	return &HTTP{Service: service}
}

// Start starts the HTTP server
func (s *HTTP) Start() {
	h := apihttp.NewHandler(s.Service)
	log.Println("HTTP server on :8080")
	log.Fatal(http.ListenAndServe(":8080", h))
}
