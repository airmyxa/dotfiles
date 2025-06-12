package http

import (
	"encoding/json"
	"net/http"
	"time"

	cfgsvc "github.com/example/config-provider-server/internal/config"
	"github.com/gorilla/mux"
)

func NewHandler(svc *cfgsvc.Service) http.Handler {
	r := mux.NewRouter()
	r.HandleFunc("/configs", createConfig(svc)).Methods("POST")
	r.HandleFunc("/configs/{name}", getConfig(svc)).Methods("GET")
	r.HandleFunc("/configs/{name}", updateConfig(svc)).Methods("PUT")
	r.HandleFunc("/configs/{name}", deleteConfig(svc)).Methods("DELETE")
	r.HandleFunc("/configs/updates", getUpdated(svc)).Methods("GET")

	// Add endpoints for metadata
	r.HandleFunc("/configs/{name}/metadata", createMetadata(svc)).Methods("POST")
	r.HandleFunc("/configs/{name}/metadata", getMetadata(svc)).Methods("GET")
	r.HandleFunc("/configs/{name}/metadata", updateMetadata(svc)).Methods("PUT")

	r.HandleFunc("/health", healthCheck()).Methods("GET")
	return r
}

// healthCheck handles the health endpoint
func healthCheck() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{"status": "healthy"})
	}
}

type createConfigRequest struct {
	Name string                 `json:"name"`
	Data map[string]interface{} `json:"data"`
}

type updateConfigRequest struct {
	Data map[string]interface{} `json:"data"`
}

type metadataRequest struct {
	Description string   `json:"description"`
	Maintainers []string `json:"maintainers"`
}

func createConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req createConfigRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		c, err := svc.Create(r.Context(), req.Name, req.Data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func getConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]

		// Check if a specific timestamp is requested
		timestampStr := r.URL.Query().Get("timestamp")
		if timestampStr != "" {
			t, err := time.Parse(time.RFC3339, timestampStr)
			if err != nil {
				http.Error(w, "invalid timestamp format", http.StatusBadRequest)
				return
			}
			c, err := svc.GetAtTime(r.Context(), name, t)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			json.NewEncoder(w).Encode(c)
			return
		}

		// Get the latest version
		c, err := svc.Get(r.Context(), name)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func updateConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]
		var req updateConfigRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		c, err := svc.Update(r.Context(), name, req.Data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func deleteConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]
		if err := svc.Delete(r.Context(), name); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func createMetadata(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]
		var req metadataRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		metadata, err := svc.CreateMetadata(r.Context(), name, req.Description, req.Maintainers)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(metadata)
	}
}

func getMetadata(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]
		metadata, err := svc.GetMetadata(r.Context(), name)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(metadata)
	}
}

func updateMetadata(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		name := mux.Vars(r)["name"]
		var req metadataRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		metadata, err := svc.UpdateMetadata(r.Context(), name, req.Description, req.Maintainers)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(metadata)
	}
}

func getUpdated(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		sinceStr := r.URL.Query().Get("since")
		t, err := time.Parse(time.RFC3339, sinceStr)
		if err != nil {
			http.Error(w, "invalid time", http.StatusBadRequest)
			return
		}
		cfgs, err := svc.UpdatedSince(r.Context(), t)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(cfgs)
	}
}
