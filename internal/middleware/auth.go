package middleware

import (
	"log"
	"net/http"

	"github.com/mirsafari/oauth-keycloak-go/internal/auth"
)

func RequireAuth(auth *auth.AuthService) func(http.Handler) http.Handler {
	middleware := func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			session, err := auth.GetSessionUser(r)
			if err != nil {
				log.Println("User is not authenticated!")
				http.Redirect(w, r, "/login", http.StatusTemporaryRedirect)
				return
			}

			log.Printf("User is authenticated! user: %v", session.FirstName)
			log.Printf("User is authenticated! user: %v", session.RawData)
			next.ServeHTTP(w, r)
		})
	}
	return middleware
}
