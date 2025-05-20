package config

import (
	"fmt"
	"os"
	"strconv"
)

type Config struct {
	HTTP_PORT      int
	LISTEN_ADDRESS string
}

var EnVars = initConfig()
var defaultApplicationPort = 1407
var defaultListenAddress = "127.0.0.1"
var sessionMaxAgeSeconds int = 3600 // 1 day

func initConfig() Config {
	return Config{
		HTTP_PORT:      getEnvInt("PORT", defaultApplicationPort),
		LISTEN_ADDRESS: getEnvString("LISTEN_ADDRESS", defaultListenAddress),
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
