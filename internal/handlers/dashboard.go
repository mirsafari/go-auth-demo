package handlers

import (
	"log"
	"net/http"

	"github.com/mirsafari/oauth-keycloak-go/internal/web/views"
)

func (h *Handler) Dashboard(w http.ResponseWriter, r *http.Request) {
	user, err := h.auth.GetSessionUser(r)
	if err != nil {
		log.Println(err)
		return
	}
	views.Homepage(user).Render(r.Context(), w)
}
