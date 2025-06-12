package config

import (
	"database/sql/driver"
	"encoding/json"
	"errors"
	"time"
)

// Config represents a configuration entry
type Config struct {
	Name      string    `db:"name" json:"name"`
	Data      JSONB     `db:"data" json:"data"`
	UpdatedAt time.Time `db:"updated_at" json:"updated_at"`
}

// ConfigMetadata represents metadata for a config
type ConfigMetadata struct {
	ConfigName  string   `db:"config_name" json:"config_name"`
	Description string   `db:"description" json:"description"`
	Maintainers []string `db:"maintainers" json:"maintainers"`
}

// JSONB is a custom type to handle PostgreSQL JSONB data
type JSONB map[string]interface{}

// Value implements the driver.Valuer interface
func (j JSONB) Value() (driver.Value, error) {
	if j == nil {
		return nil, nil
	}
	return json.Marshal(j)
}

// Scan implements the sql.Scanner interface
func (j *JSONB) Scan(src interface{}) error {
	if src == nil {
		*j = nil
		return nil
	}

	var source []byte
	switch v := src.(type) {
	case string:
		source = []byte(v)
	case []byte:
		source = v
	default:
		return errors.New("incompatible type for JSONB")
	}

	return json.Unmarshal(source, j)
}
