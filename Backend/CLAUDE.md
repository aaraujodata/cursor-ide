# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Platziflix is an online course platform backend built with FastAPI and PostgreSQL. The project implements a minimalist approach focused on core functionality: courses, classes (lessons), and teachers. This is part of a multi-platform ecosystem with TypeScript frontend and native mobile apps (iOS/Android).

## Development Commands

### Docker Environment

Start development environment:
```bash
make start
# or: docker-compose up -d
```

Stop containers:
```bash
make stop
```

View logs:
```bash
make logs
```

Rebuild containers:
```bash
make build
```

### Database Migrations

The project uses Alembic for database migrations. All migration commands must be run inside the Docker container.

Run migrations:
```bash
make migrate
# or: docker-compose exec api bash -c "cd /app && uv run alembic -c app/alembic.ini upgrade head"
```

Create new migration:
```bash
make create-migration
# This will prompt for a migration message
# or manually: docker-compose exec api bash -c "cd /app && uv run alembic -c app/alembic.ini revision --autogenerate -m 'message'"
```

Check migration status:
```bash
docker-compose exec api bash -c "cd /app && uv run alembic -c app/alembic.ini current"
```

### Database Seeding

Populate database with sample data:
```bash
make seed
```

Clear and recreate seed data:
```bash
make seed-fresh
```

### Dependency Management

This project uses `uv` for Python dependency management (defined in `pyproject.toml`).

Add a new dependency:
```bash
# Add to pyproject.toml dependencies array, then rebuild container
make build
```

## Architecture

### Project Structure

```
app/
├── core/          # Application configuration (settings)
├── models/        # SQLAlchemy models (Course, Lesson, Teacher, etc.)
├── services/      # Business logic layer (CourseService, etc.)
├── db/            # Database utilities (session management, seeding)
├── alembic/       # Database migration files
└── main.py        # FastAPI application entry point
```

### Layered Architecture

1. **API Layer** (`main.py`): FastAPI routes and dependency injection
2. **Service Layer** (`services/`): Business logic and data transformation
3. **Model Layer** (`models/`): SQLAlchemy ORM models with relationships
4. **Database Layer** (`db/`): Session management and database utilities

### Key Patterns

**Dependency Injection**: Services are injected into routes using FastAPI's `Depends()` mechanism:
```python
def get_course_service(db: Session = Depends(get_db)) -> CourseService:
    return CourseService(db)

@app.get("/courses")
def get_courses(course_service: CourseService = Depends(get_course_service)):
    return course_service.get_all_courses()
```

**Service Pattern**: Business logic is encapsulated in service classes (`CourseService`) that receive a database session via constructor injection.

**Soft Deletes**: All models inherit from `BaseModel` which includes `deleted_at` field. Queries must filter `deleted_at.is_(None)` to exclude soft-deleted records.

**Eager Loading**: Use SQLAlchemy's `joinedload()` to avoid N+1 queries when loading relationships:
```python
course = db.query(Course).options(
    joinedload(Course.teachers),
    joinedload(Course.lessons)
).filter(...)
```

## Data Models

### Entities

- **Course**: Courses with name, description, thumbnail, slug
- **Lesson** (aka "Class"): Individual lessons belonging to a course, includes video URL
- **Teacher**: Instructors who can teach multiple courses
- **CourseTeacher**: Many-to-many association between courses and teachers

### Relationships

- Course ↔ Teacher: Many-to-many via `course_teachers` table
- Course → Lesson: One-to-many with cascade delete
- All entities support soft delete via `deleted_at` field

### Model Inheritance

All models extend `BaseModel` which provides:
- `id`: Primary key
- `created_at`: Timestamp (auto-set on creation)
- `updated_at`: Timestamp (auto-updated on modification)
- `deleted_at`: Nullable timestamp for soft deletes

## API Contracts

The API follows contracts defined in `specs/00_contracts.md`.

### Important Contract Details

1. **GET /courses**: Returns list of courses WITHOUT teachers or classes
2. **GET /courses/{slug}**: Returns full course details WITH `teacher_id` array and `classes` array
3. **GET /courses/{slug}/classes/{id}**: Returns individual class with `video_url` (not yet implemented)

### Response Format

Note: The contract specifies `classes` (not `lessons`) in responses, even though the model is named `Lesson`.

## Database

### Connection

PostgreSQL runs on port **5433** on the host (mapped from container port 5432) to avoid conflicts with existing installations.

Connection details:
- Host: localhost (or `db` from within containers)
- Port: 5433 (host) / 5432 (container)
- Database: platziflix_db
- User: platziflix_user
- Password: platziflix_password

### Environment Variables

Database URL is configured via `DATABASE_URL` environment variable in `docker-compose.yml`. Settings are loaded using Pydantic Settings from `app/core/config.py`.

## Testing

The project includes pytest as a dev dependency. Tests can be run inside the container:

```bash
docker-compose exec api bash -c "cd /app && uv run pytest"
```

## Important Notes

- **Terminology**: The codebase uses "Lesson" as the model name, but the API contract and responses use "classes" for backward compatibility
- **Migration Path**: All migration commands must include `-c app/alembic.ini` because alembic files are in the `app/` subdirectory
- **Working Directory**: Commands inside the container must `cd /app` first since that's the WORKDIR
- **Hot Reload**: The API container runs with `--reload` flag, so code changes are automatically reflected
- **uv Prefix**: All Python commands inside the container must use `uv run` prefix for proper environment management
