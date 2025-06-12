-- Create database schema for the config provider service
CREATE TABLE IF NOT EXISTS configs (
    name TEXT PRIMARY KEY,
    data JSONB NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups by update time
CREATE INDEX IF NOT EXISTS idx_configs_updated_at ON configs(updated_at);

-- Create a new metadata table to store config metadata
CREATE TABLE IF NOT EXISTS config_metadata (
    config_name TEXT PRIMARY KEY REFERENCES configs(name) ON DELETE CASCADE,
    description TEXT,
    maintainers JSONB DEFAULT '[]'::jsonb
); 