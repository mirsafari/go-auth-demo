package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/mirsafari/oauth-keycloak-go/internal/auth"
	"github.com/mirsafari/oauth-keycloak-go/internal/config"
	"github.com/mirsafari/oauth-keycloak-go/internal/handlers"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	sessionStore := auth.NewCookieStore(auth.SessionOptions{
		SessionKey: config.EnVars.SESSION_KEY,
		MaxAge:     config.EnVars.SESSION_MAX_AGE,
		HttpOnly:   config.EnVars.SESSION_JS_ACCESS,
		Secure:     config.EnVars.SESSION_OVER_HTTPS,
	})

	authService := auth.NewAuthService(sessionStore, auth.OIDCServiceOptions{
		ClientID:     config.EnVars.OIDC_CLIENT_ID,
		ClientSecret: config.EnVars.OIDC_CLIENT_SECRET,
		CallbackURL:  config.EnVars.OIDC_CALLBACK_URL,
		DiscoveryURL: config.EnVars.OIDC_DISCOVERY_URL,
	})

	h := handlers.New(authService)

	r.Get("/auth/{provider}", h.HandleProviderLogin)
	r.Get("/auth/{provider}/callback", h.HandleAuthCallback)
	r.Get("/auth/logout/{provider}", h.HandleProviderLogout)
	r.Get("/auth/login", h.HandleLogin)

	r.Get("/projects", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("this is protected route visible only to logged in users"))
	})

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("welcome"))
	})

	http.ListenAndServe(fmt.Sprintf(":%s", fmt.Sprintf("%d", config.EnVars.HTTP_PORT)), r)
}
