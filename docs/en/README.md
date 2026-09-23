# Chefify documentation

[Українська версія](../uk/README.md) · [Root README](../../README.md)

This documentation is intended for developers, testers, and new project contributors.

## Sections

- [Getting started](getting-started.md) — requirements, first startup, service URLs, and local environment reset.
- [Installing Flutter SDK](flutter-setup.md) — automatic or manual setup of pinned Flutter `3.41.9`.
- [Local development](development.md) — Flutter, backend, common commands, and runtime modes.
- [Configuration](configuration.md) — environment variables, ports, secrets, API URL, CORS, and S3.
- [Architecture](architecture.md) — repository layout, frontend layers, backend, and data flows.
- [API](api.md) — endpoint groups, authorization, Swagger, and current limitations.
- [Frontend → backend contract](frontend-backend-contract.md) — exact data and API changes required by the prepared profile and recipe screens.
- [Testing and QA](testing.md) — automated checks, smoke checklist, and defect reporting.
- [Troubleshooting](troubleshooting.md) — common Docker, Flutter, API, database, and network issues.

## Shortest startup path

```powershell
Copy-Item .env.example .env
docker compose --profile frontend up --build
```

Open <http://localhost:8088>. See [Getting started](getting-started.md) for the complete procedure.

## Documentation maintenance rule

Documentation must describe the actual state of `dev`. Any change to commands, ports, configuration, API contracts, or project structure must update the corresponding files in both `docs/uk` and `docs/en`.
