package db

import (
	"github.com/jmoiron/sqlx"
)

// DB represents the database interface
type DB interface {
	*sqlx.DB
}
