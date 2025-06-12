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
	ConfigName  string          `db:"config_name" json:"config_name"`
	Description string          `db:"description" json:"description"`
	Maintainers MaintainerArray `db:"maintainers" json:"maintainers"`
}

// MaintainerArray is a custom type to handle string arrays in the database
type MaintainerArray []string

// Value implements the driver.Valuer interface
func (m MaintainerArray) Value() (driver.Value, error) {
	if m == nil {
		return nil, nil
	}
	return json.Marshal(m)
}

// Scan implements the sql.Scanner interface
func (m *MaintainerArray) Scan(src interface{}) error {
	if src == nil {
		*m = nil
		return nil
	}

	var source []byte
	switch v := src.(type) {
	case string:
		source = []byte(v)
	case []byte:
		source = v
	default:
		return errors.New("incompatible type for MaintainerArray")
	}

	return json.Unmarshal(source, m)
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
