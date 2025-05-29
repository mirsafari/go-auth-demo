package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	chimiddleware "github.com/go-chi/chi/v5/middleware"
	"github.com/mirsafari/oauth-keycloak-go/internal/config"
	"github.com/mirsafari/oauth-keycloak-go/internal/handlers"
	"github.com/mirsafari/oauth-keycloak-go/internal/middleware"
)

//go:embed assets/**/*
var embeddedAssets embed.FS

func main() {
	r := chi.NewRouter()
	r.Use(chimiddleware.Logger)
	r.Use(chimiddleware.Heartbeat("/api/health"))
	r.Use(chimiddleware.Recoverer)
	r.Use(chimiddleware.StripSlashes)
	r.Use(middleware.StoreUserInfoToContext)

	assetsFS, err := fs.Sub(embeddedAssets, "assets")
	if err != nil {
		log.Fatalf("Failed to create sub filesystem: %v", err)
	}

	r.Handle("/assets/*", http.StripPrefix("/assets/", http.FileServer(http.FS(assetsFS))))

	r.Get("/", handlers.GetDashboard)
	r.Get("/manage-tenants", handlers.GetTenantsDashboard)

	fmt.Println("Starting webserver: " + config.EnVars.LISTEN_ADDRESS + ":" + fmt.Sprintf("%d", config.EnVars.HTTP_PORT))
	http.ListenAndServe(fmt.Sprintf("%s:%d", config.EnVars.LISTEN_ADDRESS, config.EnVars.HTTP_PORT), r)
}
