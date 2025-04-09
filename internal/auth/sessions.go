package auth

import (
	"github.com/gorilla/sessions"
	"github.com/quasoft/memstore"
)

const (
	SessionName = "session"
)

type SessionOptions struct {
	SessionKey string
	MaxAge     int
	HttpOnly   bool // Prevent JavaScript access
	Secure     bool // True for sites served over HTTPS
}

func NewCookieStore(opts SessionOptions) *sessions.CookieStore {
	store := sessions.NewCookieStore([]byte(opts.SessionKey))

	store.MaxAge(opts.MaxAge)
	store.Options.Path = "/"
	store.Options.HttpOnly = opts.HttpOnly
	store.Options.Secure = opts.Secure

	return store
}

func NewMemoryStore(opts SessionOptions) *memstore.MemStore {
	store := memstore.NewMemStore(
		[]byte(opts.SessionKey),
		[]byte("enckey12341234567890123456789012"),
	)

	return store
}
