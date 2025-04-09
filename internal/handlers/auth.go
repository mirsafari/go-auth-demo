package handlers

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/markbates/goth/gothic"
	"github.com/mirsafari/oauth-keycloak-go/internal/web/views"
)

func (h *Handler) LoginPage(w http.ResponseWriter, r *http.Request) {
	views.LoginForm().Render(r.Context(), w)
}

func (h *Handler) HandleProviderLogin(w http.ResponseWriter, r *http.Request) {
	// gotihc expect provider as context value, so we pull it from url and store in http.Request
	provider := chi.URLParam(r, "provider")
	r = r.WithContext(context.WithValue(context.Background(), "provider", provider))

	// try to get the user without re-authenticating
	if u, err := gothic.CompleteUserAuth(w, r); err == nil {
		log.Printf("User already authenticated! %v", u)

		views.Homepage(u).Render(r.Context(), w)
	} else {
		gothic.BeginAuthHandler(w, r)
	}
}

// Keycloak redirets to this URL, the session is created and stored in cookie
func (h *Handler) HandleAuthCallback(w http.ResponseWriter, r *http.Request) {
	user, err := gothic.CompleteUserAuth(w, r)
	if err != nil {
		fmt.Fprintln(w, err)
		return
	}

	err = h.auth.StoreUserSession(w, r, user)
	if err != nil {
		log.Println(err)
		return
	}

	w.Header().Set("Location", "/")
	w.WriteHeader(http.StatusTemporaryRedirect)
}

// Removes the session and logs the user out
func (h *Handler) HandleProviderLogout(w http.ResponseWriter, r *http.Request) {

	err := gothic.Logout(w, r)
	if err != nil {
		log.Println(err)
		return
	}

	h.auth.RemoveUserSession(w, r)

	w.Header().Set("Location", "/login")
	w.WriteHeader(http.StatusTemporaryRedirect)
}
