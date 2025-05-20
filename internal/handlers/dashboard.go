package handlers

import (
	"net/http"

	"github.com/mirsafari/oauth-keycloak-go/internal/web/views"
)

func GetDashboard(w http.ResponseWriter, r *http.Request) {
	views.Homepage().Render(r.Context(), w)
}
