package handlers

import (
	"net/http"

	"github.com/mirsafari/oauth-keycloak-go/internal/middleware"
	"github.com/mirsafari/oauth-keycloak-go/internal/models"
	"github.com/mirsafari/oauth-keycloak-go/internal/web/views"
)

func GetDashboard(w http.ResponseWriter, r *http.Request) {

	user, ok := r.Context().Value(middleware.UserContextKey).(*models.User)
	if !ok {
		http.Error(w, "forbidden - H", http.StatusForbidden)
		return
	}

	views.Homepage(user).Render(r.Context(), w)
}
