package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/mirsafari/oauth-keycloak-go/internal/config"
	"github.com/mirsafari/oauth-keycloak-go/internal/handlers"
	"github.com/mirsafari/oauth-keycloak-go/internal/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Heartbeat("/api/health"))
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.StripSlashes)
	r.Use(middleware.StoreUserInfoToContext)

	r.Get("/", handlers.GetDashboard)

	fmt.Println("Starting webserver: " + config.EnVars.LISTEN_ADDRESS + ":" + fmt.Sprintf("%d", config.EnVars.HTTP_PORT))
	http.ListenAndServe(fmt.Sprintf("%s:%d", config.EnVars.LISTEN_ADDRESS, config.EnVars.HTTP_PORT), r)
}
