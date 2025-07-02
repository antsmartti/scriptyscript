CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS documents (
    id serial PRIMARY KEY,
    content text,
    embedding vector(1536)
);