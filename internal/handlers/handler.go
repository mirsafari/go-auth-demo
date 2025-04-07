package handlers

import "github.com/mirsafari/oauth-keycloak-go/internal/auth"

type Handler struct {
	auth *auth.AuthService
}

func New(auth *auth.AuthService) *Handler {
	return &Handler{
		auth: auth,
	}
}
