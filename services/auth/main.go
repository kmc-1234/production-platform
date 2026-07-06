package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"
	"time"
)

func main() {
	port := env("APP_PORT", "8081")
	mux := http.NewServeMux()
	mux.HandleFunc("/healthz", health)
	mux.HandleFunc("/readyz", health)
	mux.HandleFunc("/auth/register", register)
	mux.HandleFunc("/auth/login", login)

	server := &http.Server{Addr: ":" + port, Handler: mux, ReadHeaderTimeout: 5 * time.Second}
	log.Printf("auth listening on :%s", port)
	log.Fatal(server.ListenAndServe())
}

func health(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{"service": "auth", "status": "ok"})
}

func register(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	writeJSON(w, http.StatusCreated, map[string]string{"status": "registered"})
}

func login(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		w.WriteHeader(http.StatusMethodNotAllowed)
		return
	}
	var input struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil || !strings.Contains(input.Email, "@") || input.Password == "" {
		writeJSON(w, http.StatusUnauthorized, map[string]string{"error": "invalid credentials"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]string{"token": sign(input.Email), "tokenType": "Bearer"})
}

func sign(subject string) string {
	header := b64(`{"alg":"HS256","typ":"JWT"}`)
	claims, _ := json.Marshal(map[string]interface{}{
		"sub": subject,
		"iss": env("APP_NAME", "auth"),
		"exp": time.Now().Add(time.Hour).Unix(),
	})
	payload := b64(string(claims))
	unsigned := header + "." + payload
	mac := hmac.New(sha256.New, []byte(env("JWT_SECRET", "change-me")))
	mac.Write([]byte(unsigned))
	return unsigned + "." + base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}

func b64(value string) string {
	return base64.RawURLEncoding.EncodeToString([]byte(value))
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
