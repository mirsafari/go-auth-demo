package handlers

import (
	"net/http"
)

// Renderes the login page
func (h *Handler) HandleLogin(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("This is login"))
}

// Start the auth process by redirect to Keycloak
func (h *Handler) HandleProviderLogin(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("This is login"))
}

// Keycloak redirets to this URL, the session is created and stored in cookie
func (h *Handler) HandleAuthCallback(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("This is login"))
}

// Removes the session and logs the user out
func (h *Handler) HandleProviderLogout(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("This is login"))
}
