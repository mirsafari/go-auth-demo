package auth

import (
	"github.com/gorilla/sessions"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/openidConnect"
)

type AuthService struct{}

type OIDCServiceOptions struct {
	ClientID     string
	ClientSecret string
	CallbackURL  string
	DiscoveryURL string
}

func NewAuthService(store sessions.Store, opts OIDCServiceOptions) *AuthService {
	gothic.Store = store

	openidConnect, _ := openidConnect.New(
		opts.ClientID,
		opts.ClientSecret,
		opts.CallbackURL,
		opts.DiscoveryURL,
	)

	if openidConnect != nil {
		goth.UseProviders(openidConnect)
	}

	return &AuthService{}
}
