-- Create database schema for the config provider service
CREATE TABLE IF NOT EXISTS configs (
    id TEXT PRIMARY KEY,
    data TEXT NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups by update time
CREATE INDEX IF NOT EXISTS idx_configs_updated_at ON configs(updated_at); 