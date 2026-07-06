package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

type product struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Price     float64   `json:"price"`
	CreatedAt time.Time `json:"createdAt"`
}

type response struct {
	Service string      `json:"service"`
	Data    interface{} `json:"data,omitempty"`
	Error   string      `json:"error,omitempty"`
}

var (
	mu       sync.RWMutex
	products = []product{
		{ID: 1, Name: "Starter Plan", Price: 19, CreatedAt: time.Now().UTC()},
		{ID: 2, Name: "Production Plan", Price: 99, CreatedAt: time.Now().UTC()},
	}
	nextID = 3
)

func main() {
	port := env("APP_PORT", "8080")

	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", health)
	mux.HandleFunc("/readyz", health)
	mux.HandleFunc("/api/products", productsHandler)
	mux.HandleFunc("/api/orders", ordersHandler)

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           withLogging(mux),
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("backend listening on :%s", port)
	log.Fatal(server.ListenAndServe())
}

func health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, response{Service: "backend", Data: map[string]string{"status": "ok"}})
}

func productsHandler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		mu.RLock()
		defer mu.RUnlock()
		writeJSON(w, http.StatusOK, response{Service: "backend", Data: products})
	case http.MethodPost:
		var input struct {
			Name  string  `json:"name"`
			Price float64 `json:"price"`
		}
		if err := json.NewDecoder(r.Body).Decode(&input); err != nil || input.Name == "" {
			writeJSON(w, http.StatusBadRequest, response{Service: "backend", Error: "invalid product payload"})
			return
		}
		mu.Lock()
		item := product{ID: nextID, Name: input.Name, Price: input.Price, CreatedAt: time.Now().UTC()}
		nextID++
		products = append(products, item)
		mu.Unlock()
		writeJSON(w, http.StatusCreated, response{Service: "backend", Data: item})
	default:
		w.WriteHeader(http.StatusMethodNotAllowed)
	}
}

func ordersHandler(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, response{Service: "backend", Data: []map[string]interface{}{
		{"id": 1001, "status": "paid", "total": 99},
		{"id": 1002, "status": "pending", "total": 19},
	}})
}

func withLogging(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
	})
}

func writeJSON(w http.ResponseWriter, status int, payload interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func env(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}
