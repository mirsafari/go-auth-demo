package models

import (
	"regexp"
	"time"

	"github.com/google/uuid"
)

type Tenant struct {
	ID          uuid.UUID
	Name        string
	EmailDomain domain
	IsActive    bool
	CreatedAt   time.Time
	CreatedBy   string
}

type domain string

var domainRegex = regexp.MustCompile(`^(?:[a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$`)

func (d domain) IsValid() bool {
	return domainRegex.MatchString(string(d))
}

type TenantUser struct {
	ID                uuid.UUID
	TenantID          uuid.UUID
	Roles             Roles
	IsActive          bool
	ExternalID        string
	Email             string
	PreferredUsername string
	Locale            string
	AppTheme          string
	HourlyRate        float32
}

type Roles map[string]struct{}

// Check membership
func (r Roles) Has(role string) bool {
	_, ok := r[role]
	return ok
}
