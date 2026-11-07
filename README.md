# MeritLens — AI-Powered Recruitment Assessment System

**MeritLens** is an AI-powered recruitment assessment system designed to help recruiters evaluate candidate resumes against job-specific requirements using Retrieval-Augmented Generation (RAG).

The system combines Google Gemini, n8n workflow automation, PostgreSQL, and pgvector to generate structured, evidence-based assessments, identify missing qualifications, suggest technical evaluations, and support human review.

MeritLens is designed as a decision-support tool. It does not automatically hire, reject, rank, or score candidates.

## Project Objectives

- Automate the initial analysis of candidate resumes.
- Compare candidate qualifications against dynamically selected job descriptions.
- Use RAG to retrieve relevant job requirements from a knowledge base.
- Identify demonstrated, partially demonstrated, and undocumented skills.
- Generate job-specific technical interview questions and practical exercises.
- Provide structured recommendations for recruiters.
- Store assessment reports for future reference.
- Support human review and assessment status tracking.

## Technology Stack

| Technology | Purpose |
|---|---|
| n8n | Workflow orchestration and form-based interactions |
| Google Gemini | AI assessment generation and embeddings |
| PostgreSQL 17 | Relational database for assessment records |
| pgvector | Vector storage and similarity search |
| Docker Compose | Containerized local deployment |
| JavaScript Expressions | Dynamic workflow data processing |
| SQL | Data retrieval, validation, and updates |

The knowledge base uses the `models/gemini-embedding-001` embedding model with 3072-dimensional vectors.

## System Architecture

MeritLens consists of five interconnected functional workflows.

### Workflow 01 — Knowledge Base Ingestion

**Purpose:** Allow recruiters to add job descriptions to the recruitment knowledge base.

**Process:**

1. Recruiter submits a job reference, title, and description through an n8n form.
2. The workflow prepares and validates the incoming job information.
3. PostgreSQL checks whether the job reference already exists.
4. Existing references are routed to a duplicate-warning response.
5. New descriptions are processed using Google Gemini embeddings.
6. PGVector stores the job content, embedding, and metadata.
7. A completion response is prepared for the recruiter.

**Key features:**
- Dynamic job-description submission
- Job-reference metadata
- Duplicate-reference detection
- Vector embeddings
- Structured ingestion responses

### Workflow 02 — RAG Recruitment Agent

**Purpose:** Generate evidence-based candidate assessments against selected job descriptions.

**Process:**

1. Recruiter enters a job reference and uploads a PDF resume.
2. The workflow extracts text from the PDF.
3. PostgreSQL validates the selected job reference.
4. Invalid references are routed to an error response.
5. The AI Agent retrieves relevant job-description content using PGVector.
6. Google Gemini compares the resume with the job requirements.
7. The agent generates a structured assessment.
8. PostgreSQL stores the assessment with a pending-review status.

**Assessment output includes:**
- Selected job reference and position
- Candidate background summary
- Required skills evidence table
- Preferred skills evidence table
- Missing information
- Recruiter action recommendations
- Suggested technical assessments
- Targeted interview questions
- Follow-up information
- Human review checklist

Skills are classified as:

- **Demonstrated:** Supported by documented resume evidence.
- **Partially Demonstrated:** Related experience exists, but the full requirement is not established.
- **Not Evidenced:** The resume does not provide sufficient evidence for the requirement.

Missing evidence is not treated as proof that a candidate lacks a skill.

### Workflow 03 — Human Review

**Purpose:** Allow recruiters to record human review progress and notes.

**Process:**

1. Reviewer enters an Assessment ID.
2. Reviewer selects a review status.
3. Reviewer submits notes.
4. PostgreSQL updates the corresponding assessment.
5. The workflow prepares a success or not-found confirmation.

**Supported statuses:**
- `pending_review`
- `in_review`
- `reviewed`

The system records a review timestamp when the status is set to `reviewed`.

### Workflow 04 — Assessment Review Queue

**Purpose:** Retrieve assessments awaiting human review.

The workflow queries PostgreSQL for assessments with `pending_review` or `in_review` status.

**Returned information includes:**
- Assessment ID
- Candidate reference
- Job reference
- Job title
- Review status
- Creation timestamp
- Assessment preview

The current implementation uses a manual n8n trigger rather than a standalone recruiter dashboard.

### Workflow 05 — Assessment Report Lookup

**Purpose:** Retrieve an assessment report using its unique Assessment ID.

**Process:**

1. Recruiter submits an Assessment ID through an n8n form.
2. PostgreSQL searches for the matching assessment.
3. The workflow retrieves the complete report and review information.
4. The form completion step displays the report or a not-found message.

## Database Design

### meritlens_documents

Stores job descriptions and vector embeddings.

| Column | Purpose |
|---|---|
| id | Unique document identifier |
| text | Job-description content |
| metadata | Job reference, title, and document type |
| embedding | 3072-dimensional vector |

### candidate_assessments

Stores generated assessments and human review information.

| Column | Purpose |
|---|---|
| id | Unique assessment identifier |
| candidate_reference | Candidate tracking reference |
| job_reference | Associated job reference |
| job_title | Position being assessed |
| assessment_report | Generated evidence-based report |
| review_status | Human review status |
| reviewer_notes | Reviewer comments |
| created_at | Assessment creation timestamp |
| reviewed_at | Review completion timestamp |

## Example Use Case

A recruiter submits a resume belonging to a Software Quality Assurance intern for the position of Junior Python Developer (`JOB-PY-001`).

MeritLens retrieves the Python Developer job description and evaluates the candidate's documented experience against its requirements.

For example:

| Requirement | Example classification |
|---|---|
| Python programming | Not Evidenced |
| FastAPI/Django | Not Evidenced |
| REST API development | Demonstrated |
| SQL knowledge | Demonstrated |
| Git/GitHub | Demonstrated |
| pytest | Not Evidenced |

The agent then recommends relevant technical verification exercises and follow-up questions.

The generated report is stored for human review rather than used to make an automated employment decision.

## Local Development Setup

### Prerequisites

- Docker Desktop
- Docker Compose
- n8n
- Google Gemini API credentials
- PostgreSQL with pgvector support

### Startup

Clone the repository:

```bash
git clone https://github.com/syedamahnoor-sm/meritlens.git
cd meritlens
```

Configure the required environment variables using the project's local environment configuration. Never commit actual API keys or database passwords.

Start the containers:

```bash
docker compose up -d
```

Access n8n at:

```text
http://localhost:5679
```

Import the exported n8n workflow JSON files if they are not already present in the local n8n instance.

Configure the required PostgreSQL and Google Gemini credentials inside n8n.

**Note:** A fresh deployment also requires the PostgreSQL schema, pgvector extension, and appropriate database initialization. Workflow exports alone do not recreate the database.

## Security and Responsible AI

MeritLens follows a human-in-the-loop assessment approach.

- AI-generated reports support recruiter review.
- No automated hiring or rejection decisions.
- No candidate rankings or suitability scores.
- Resume evidence is distinguished from assumptions.
- Candidate information should remain confidential.
- Credentials and environment secrets must not be committed.
- Form access should be protected before deployment.
- Production use requires appropriate authorization, privacy controls, and audit logging.

## Development and Testing Status

The five-workflow MVP has been configured.

Previously verified functionality includes:

- Job-description embedding and storage
- Job-specific RAG retrieval
- PDF resume extraction
- Evidence-based assessment generation
- Recruiter action recommendations
- Assessment storage in PostgreSQL
- Human review status updates

The latest duplicate-detection, validation, confirmation, review-queue, and report-lookup changes are configured but still require consolidated integration testing.

## Current Limitations

- The review queue currently runs inside n8n.
- Reviewers use Assessment IDs to retrieve reports and update review status.
- Duplicate prevention is application-level rather than database-enforced.
- Some form completion and error-handling paths remain unverified.
- Production-grade authorization, auditing, and privacy safeguards are not yet implemented.
- The system currently focuses on text-based PDF resume processing.

## Future Enhancements

- Unified recruiter dashboard
- Searchable assessment history
- Role-based recruiter access
- Improved PDF and DOCX handling
- Structured assessment export
- Database-enforced job-reference uniqueness
- Versioned job descriptions
- Audit trails and review history
- Production deployment and monitoring

## Project Status

**MVP feature configuration complete — final integration testing pending.**

MeritLens demonstrates the use of Retrieval-Augmented Generation, vector databases, workflow automation, and human-in-the-loop review in a practical recruitment assessment system.

## Author

Developed as a software engineering project exploring AI-powered workflow automation and evidence-based recruitment support.