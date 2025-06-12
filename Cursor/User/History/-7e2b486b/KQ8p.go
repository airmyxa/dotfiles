package database

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/jackc/pgx/v5/stdlib"
)

// TestPostgresProvider implements Provider interface for testing
type TestPostgresProvider struct {
	DB             *sqlx.DB
	containerID    string
	containerName  string
	migrationPaths []string
}

// NewTestPostgresProvider creates a test provider with a Docker PostgreSQL instance
func NewTestPostgresProvider(migrationPaths []string) (*TestPostgresProvider, error) {
	containerName := fmt.Sprintf("pg-test-%d", time.Now().UnixNano())

	// Start PostgreSQL container
	cmd := exec.Command(
		"docker", "run", "--rm", "-d",
		"--name", containerName,
		"-e", "POSTGRES_USER=postgres",
		"-e", "POSTGRES_PASSWORD=postgres",
		"-e", "POSTGRES_DB=configs_test",
		"-p", "0:5432",
		"postgres:16-alpine",
	)
	output, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("failed to start PostgreSQL container: %v, output: %s", err, output)
	}
	
	containerID := strings.TrimSpace(string(output))

	// Get the mapped port
	cmd = exec.Command("docker", "port", containerName, "5432/tcp")
	output, err = cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("failed to get container port: %v, output: %s", err, output)
	}
	
	portMapping := strings.TrimSpace(string(output))
	port := strings.Split(portMapping, ":")[1]

	dsn := fmt.Sprintf("postgres://postgres:postgres@localhost:%s/configs_test?sslmode=disable", port)

	// Wait for PostgreSQL to be ready
	for i := 0; i < 30; i++ {
		db, err := sqlx.Connect("pgx", dsn)
		if err == nil {
			// Apply migrations
			for _, migrationPath := range migrationPaths {
				migrationSQL, err := os.ReadFile(migrationPath)
				if err != nil {
					db.Close()
					return nil, fmt.Errorf("failed to read migration file %s: %v", migrationPath, err)
				}

				_, err = db.Exec(string(migrationSQL))
				if err != nil {
					db.Close()
					return nil, fmt.Errorf("failed to apply migration %s: %v", migrationPath, err)
				}
			}

			return &TestPostgresProvider{
				DB:             db,
				containerID:    containerID,
				containerName:  containerName,
				migrationPaths: migrationPaths,
			}, nil
		}
		time.Sleep(1 * time.Second)
	}

	return nil, fmt.Errorf("timeout waiting for PostgreSQL container to be ready")
}

// Close stops and removes the PostgreSQL container
func (p *TestPostgresProvider) Close() error {
	if p.DB != nil {
		p.DB.Close()
	}

	if p.containerName != "" {
		cmd := exec.Command("docker", "stop", p.containerName)
		if output, err := cmd.CombinedOutput(); err != nil {
			return fmt.Errorf("failed to stop container: %v, output: %s", err, output)
		}
	}

	return nil
}

// ProvideTestDB provides the test database connection
func ProvideTestDB(p *TestPostgresProvider) *sqlx.DB {
	return p.DB
}

// ResetDatabase clears all data from the database but keeps the schema
func (p *TestPostgresProvider) ResetDatabase(ctx context.Context) error {
	// Delete all data but keep the schema
	_, err := p.DB.ExecContext(ctx, `
		TRUNCATE config_metadata CASCADE;
		TRUNCATE configs CASCADE;
	`)
	return err
} 