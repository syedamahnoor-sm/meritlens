
-- MeritLens Database Schema
-- PostgreSQL 17 + pgvector

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS meritlens_documents (
    id BIGSERIAL PRIMARY KEY,
    text TEXT,
    metadata JSONB,
    embedding VECTOR(3072)
);

CREATE INDEX IF NOT EXISTS idx_meritlens_documents_metadata
ON meritlens_documents USING GIN (metadata);

CREATE TABLE IF NOT EXISTS candidate_assessments (
    id BIGSERIAL PRIMARY KEY,
    candidate_reference VARCHAR(100),
    job_reference VARCHAR(100),
    job_title VARCHAR(200) NOT NULL,
    assessment_report TEXT NOT NULL,
    review_status VARCHAR(30) NOT NULL DEFAULT 'pending_review',
    reviewer_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,

    CONSTRAINT valid_review_status
    CHECK (
        review_status IN (
            'pending_review',
            'in_review',
            'reviewed'
        )
    )
);

CREATE INDEX IF NOT EXISTS idx_candidate_assessments_status
ON candidate_assessments (review_status);

CREATE INDEX IF NOT EXISTS idx_candidate_assessments_job_reference
ON candidate_assessments (job_reference);
