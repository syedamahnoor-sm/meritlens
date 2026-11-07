# MeritLens — System Architecture

## Overview

MeritLens is an AI-powered recruitment assessment system built using n8n, Google Gemini, PostgreSQL, and pgvector.

It uses Retrieval-Augmented Generation (RAG) to compare candidate resumes with dynamically stored job descriptions and produce evidence-based assessment reports for human review.

## Architecture Components

| Component | Responsibility |
|---|---|
| n8n | Workflow automation, forms, and orchestration |
| Google Gemini | Assessment generation and text embeddings |
| PostgreSQL 17 | Assessment records, job metadata, and review information |
| pgvector | Job-description vector storage and retrieval |
| Docker Compose | Local application infrastructure |
| n8n Forms | Job submission, resume upload, report lookup, and review |

## Workflow Architecture

### Workflow 01 — Knowledge Base Ingestion

Job Description Form → Prepare Job Data → Check Existing Job → IF

- **Existing job:** Generate duplicate warning and completion response.
- **New job:** Restore job data → Generate embeddings → Store in PGVector → Display success confirmation.

### Workflow 02 — RAG Recruitment Agent

Resume Submission Form → Extract PDF Text → Prepare Assessment Input → Validate Job Reference → IF

- **Invalid reference:** Generate error response.
- **Valid reference:** Restore assessment input → AI Agent → PGVector retrieval → Gemini assessment → Save assessment in PostgreSQL.

The AI Agent uses the selected job reference to retrieve relevant job requirements and compare them against the candidate's documented experience.

### Workflow 03 — Human Review

Human Review Form → Review Input → Update Review Status → Human Review Confirmation.

Reviewers can update assessment status and add reviewer notes.

### Workflow 04 — Assessment Review Queue

Manual Trigger → Get Pending Assessments.

Retrieves assessments with `pending_review` or `in_review` status.

### Workflow 05 — Assessment Report Lookup

Assessment Lookup Form → Get Assessment Report → Display Assessment Report.

Allows recruiters to retrieve a complete assessment using its Assessment ID.

## Database Architecture

### meritlens_documents

Stores job descriptions, metadata, and 3072-dimensional Gemini embeddings.

### candidate_assessments

Stores assessment reports, candidate references, job references, review statuses, reviewer notes, and timestamps.

## RAG Processing

1. Job descriptions are converted into vector embeddings.
2. Embeddings and job metadata are stored in PostgreSQL using pgvector.
3. A recruiter uploads a resume and specifies a job reference.
4. The system validates the reference.
5. The AI Agent retrieves job-description content using the selected reference.
6. Gemini evaluates the candidate's documented qualifications against the retrieved requirements.
7. The resulting assessment is stored in PostgreSQL.
8. A human reviewer examines the assessment and records review progress.

## Responsible AI

MeritLens is designed to support recruiters rather than replace their judgment.

- No automated hiring or rejection decisions.
- No candidate ranking or suitability scoring.
- Missing evidence is distinguished from lack of skill.
- Human review remains necessary.
- Candidate information must be protected.

## Deployment

The application runs locally through Docker Compose.

- n8n: `http://localhost:5679`
- PostgreSQL: Docker container `meritlens-postgres`
- Embedding model: `models/gemini-embedding-001`

Google Gemini and PostgreSQL credentials are configured through n8n.

## Current Status

All five MVP workflows have been configured. Core RAG assessment and human review operations were previously tested.

The latest validation, duplicate-prevention, and form-response changes require consolidated integration testing.

## Future Enhancements

- Unified recruiter dashboard
- Role-based authorization
- Searchable assessment history
- Exportable assessment reports
- Database-enforced job-reference uniqueness
- Review audit logs
- Production deployment and monitoring
