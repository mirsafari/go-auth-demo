package models

type Roles map[string]struct{}

// User represents the authenticated user's identity from headers
type User struct {
	Roles             Roles
	PreferredUsername string
	Email             string
	UserExternalID    string
}

// Check membership
func (r Roles) Has(role string) bool {
	_, ok := r[role]
	return ok
}
