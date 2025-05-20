package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/mirsafari/oauth-keycloak-go/internal/config"
	"github.com/mirsafari/oauth-keycloak-go/internal/handlers"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Get("/", handlers.GetDashboard)

	fmt.Println("Started webserver on " + config.EnVars.LISTEN_ADDRESS + ":" + fmt.Sprintf("%d", config.EnVars.HTTP_PORT))
	http.ListenAndServe(fmt.Sprintf("%s:%d", config.EnVars.LISTEN_ADDRESS, config.EnVars.HTTP_PORT), r)
}
