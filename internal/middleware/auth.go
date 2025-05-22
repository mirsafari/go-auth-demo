package middleware

import (
	"context"
	"net/http"
	"strings"

	"github.com/mirsafari/oauth-keycloak-go/internal/models"
)

type contextKey string

const UserContextKey contextKey = "authenticatedUser"

func StoreUserInfoToContext(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		user := &models.User{
			PreferredUsername: r.Header.Get("X-Forwarded-Preferred-Username"),
			Email:             r.Header.Get("X-Forwarded-Email"),
			UserExternalID:    r.Header.Get("X-Forwarded-User"),
		}

		rawRoles := r.Header.Get("X-Forwarded-Groups")

		if rawRoles == "" || user.PreferredUsername == "" || user.Email == "" || user.UserExternalID == "" {
			http.Error(w, "forbidden - M", http.StatusForbidden)
			return
		}

		user.Roles = parseRoles(rawRoles)

		ctx := context.WithValue(r.Context(), UserContextKey, user)

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func parseRoles(raw string) models.Roles {
	roles := make(models.Roles)
	for _, entry := range strings.Split(raw, ",") {
		entry = strings.TrimSpace(entry)
		if strings.HasPrefix(entry, "role:") {
			role := strings.TrimPrefix(entry, "role:")
			roles[role] = struct{}{}
		}
	}
	return roles
}
