package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	HTTP_PORT          int
	OIDC_ENDPOINT      string
	OIDC_CLIENT_ID     string
	OIDC_CLIENT_SECRET string
	OIDC_DISCOVERY_URL string
	OIDC_CALLBACK_URL  string
	SESSION_KEY        string
	SESSION_MAX_AGE    int
	SESSION_JS_ACCESS  bool // Prevent JavaScript access
	SESSION_OVER_HTTPS bool // True for sites served over HTTPS
}

var EnVars = initConfig()
var defaultApplicationPort = 1407
var sessionMaxAgeSeconds int = 3600 // 1 day

func initConfig() Config {
	return Config{
		HTTP_PORT: getEnvInt("PORT", defaultApplicationPort),

		OIDC_ENDPOINT:      getEnvStringRequired("OIDC_ENDPOINT"),
		OIDC_CLIENT_ID:     getEnvStringRequired("OIDC_CLIENT_ID"),
		OIDC_CLIENT_SECRET: getEnvStringRequired("OIDC_CLIENT_SECRET"),
		OIDC_DISCOVERY_URL: getEnvStringRequired("OIDC_DISCOVERY_URL"),
		OIDC_CALLBACK_URL:  getEnvStringRequired("OIDC_CALLBACK_URL"),
		SESSION_KEY:        getEnvStringRequired("SESSION_KEY"),
		SESSION_MAX_AGE:    getEnvInt("SESSION_MAX_AGE", sessionMaxAgeSeconds),
		SESSION_JS_ACCESS:  getEnvBool("SESSION_JS_ACCESS", false),
		SESSION_OVER_HTTPS: getEnvBool("SESSION_OVER_HTTPS", true),
	}
}

func getEnvString(envName, defaultValue string) string {
	value, exists := os.LookupEnv(envName)

	if exists {
		return value
	}

	return defaultValue
}

func getEnvInt(envName string, defaultValue int) int {
	value, exists := os.LookupEnv(envName)

	if exists {
		val, err := strconv.Atoi(value)
		if err != nil {
			return val
		}
		fmt.Printf("Invalid value for %s. Defaulting to %d", envName, defaultValue)
	}

	return defaultValue
}

func getEnvBool(envName string, defaultValue bool) bool {
	value, exists := os.LookupEnv(envName)

	if exists {
		val, err := strconv.ParseBool(value)
		if err == nil {
			return val
		}
	}

	return defaultValue
}

func getEnvStringRequired(envName string) string {
	value, exists := os.LookupEnv(envName)
	if exists {
		return value
	}

	panic(fmt.Sprintf("Environment variable required, but not set: %s ", envName))
}
