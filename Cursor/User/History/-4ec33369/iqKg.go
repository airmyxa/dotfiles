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
	r.HandleFunc("/configs/{id}", getConfig(svc)).Methods("GET")
	r.HandleFunc("/configs/{id}", updateConfig(svc)).Methods("PUT")
	r.HandleFunc("/configs/{id}", deleteConfig(svc)).Methods("DELETE")
	r.HandleFunc("/configs/updates", getUpdated(svc)).Methods("GET")
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

type createRequest struct {
	Data string `json:"data"`
}

func createConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req createRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		c, err := svc.Create(r.Context(), req.Data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func getConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := mux.Vars(r)["id"]
		c, err := svc.Get(r.Context(), id)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func updateConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := mux.Vars(r)["id"]
		var req createRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		c, err := svc.Update(r.Context(), id, req.Data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		json.NewEncoder(w).Encode(c)
	}
}

func deleteConfig(svc *cfgsvc.Service) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		id := mux.Vars(r)["id"]
		if err := svc.Delete(r.Context(), id); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusNoContent)
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
