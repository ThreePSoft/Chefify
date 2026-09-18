# Chefify

[Українська документація](docs/uk/README.md) · [English documentation](docs/en/README.md)

Chefify is a recipe platform built as a Flutter web client, an ASP.NET Core 9 API, and PostgreSQL. The repository is under active development and contains the full local Docker environment.

## Quick start

Requirements: Git, Docker Engine or Docker Desktop, and Docker Compose v2.

```powershell
Copy-Item .env.example .env
docker compose --profile frontend up --build
```

```bash
cp .env.example .env
docker compose --profile frontend up --build
```

After startup:

- Web application: <http://localhost:8088>
- API: <http://localhost:8080>
- Swagger UI: <http://localhost:8080/swagger>

Stop the stack without deleting database data:

```bash
docker compose --profile frontend down --remove-orphans
```

## Documentation

| Topic | Українська | English |
| --- | --- | --- |
| Documentation index | [Відкрити](docs/uk/README.md) | [Open](docs/en/README.md) |
| Installation and first run | [Початок роботи](docs/uk/getting-started.md) | [Getting started](docs/en/getting-started.md) |
| Flutter SDK installation | [Встановлення Flutter](docs/uk/flutter-setup.md) | [Installing Flutter](docs/en/flutter-setup.md) |
| Local development | [Розробка](docs/uk/development.md) | [Development](docs/en/development.md) |
| Configuration | [Конфігурація](docs/uk/configuration.md) | [Configuration](docs/en/configuration.md) |
| Architecture | [Архітектура](docs/uk/architecture.md) | [Architecture](docs/en/architecture.md) |
| API | [API](docs/uk/api.md) | [API](docs/en/api.md) |
| Testing and QA | [Тестування](docs/uk/testing.md) | [Testing](docs/en/testing.md) |
| Troubleshooting | [Вирішення проблем](docs/uk/troubleshooting.md) | [Troubleshooting](docs/en/troubleshooting.md) |

## Repository layout

```text
backend/           ASP.NET Core API
frontend/          Flutter web application
docs/              Ukrainian and English documentation
tools/flutter/     Pinned Flutter setup and wrapper scripts
docker-compose.yml Local PostgreSQL, API, and web stack
```

Do not commit `.env` or real credentials. Use [.env.example](.env.example) as the local configuration template.
