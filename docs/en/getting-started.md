# Getting started

[Українська версія](../uk/getting-started.md) · [Documentation index](README.md)

## 1. Prerequisites

The recommended Docker workflow requires:

- Git;
- Docker Desktop or Docker Engine;
- Docker Compose v2 (`docker compose version`);
- free ports `5432`, `8080`, and `8088`, or custom values in `.env`.

Local development outside the full container stack additionally requires Flutter `3.41.9`, .NET SDK 9, and Chrome or another Flutter web target. A local PostgreSQL installation is optional because the database can run as a standalone Docker service.

## 2. Get the repository

```bash
git clone <repository-url>
cd Chefify
git switch dev
git status --short --branch
```

## 3. Create local configuration

PowerShell:

```powershell
Copy-Item .env.example .env
```

Bash:

```bash
cp .env.example .env
```

Git ignores `.env`. Never place production credentials in it. Template values are sufficient for local startup, but S3 file operations require real test AWS credentials and a test bucket.

At minimum, verify that:

- `POSTGRES_*` and `CONNECTION_STRING` agree;
- `JWT_KEY` contains a long local secret;
- `ADMIN_EMAIL` and `ADMIN_PASSWORD` are safe for the environment;
- configured ports are not used by another application.

See [Configuration](configuration.md) for every option.

## 4. Start the full stack

```bash
docker compose --profile frontend up --build
```

To run in the background:

```bash
docker compose --profile frontend up --build -d
```

Compose starts PostgreSQL, waits for its health check, starts the API, builds Flutter web, and serves it through nginx.

| Service | Address | Purpose |
| --- | --- | --- |
| Frontend | <http://localhost:8088> | Flutter web application |
| API | <http://localhost:8080> | ASP.NET Core API |
| Swagger | <http://localhost:8080/swagger> | API documentation in Development |
| PostgreSQL | `localhost:5432` | Local database |

On first startup, the API applies EF Core migrations automatically. When `ADMIN_EMAIL` and `ADMIN_PASSWORD` are set, it creates the local administrator unless a user with that email already exists.

## 5. Verify startup

```bash
docker compose ps
docker compose logs --tail=100 api
docker compose logs --tail=100 frontend-web
```

Expected state:

- `db` is healthy;
- `api` does not exit with a configuration exception;
- `frontend-web` listens on the configured HTTP port;
- `GET http://localhost:8080/api/Recipes` returns JSON or an empty array;
- opening <http://localhost:8088/recipes> directly loads the SPA instead of an nginx 404.

## 6. Stop and restart

```bash
docker compose --profile frontend down --remove-orphans
docker compose --profile frontend up --build -d
```

A regular `down` does not delete PostgreSQL data.

## 7. Reset all local data

The following command deletes the Docker volume containing the local database. Do not use it when the data must be preserved.

```bash
docker compose --profile frontend down --volumes --remove-orphans
docker compose --profile frontend up --build -d
```

## 8. Next steps

- Developers: [Local development](development.md).
- Testers: [Testing and QA](testing.md).
- API consumers: [API](api.md).
- Startup failures: [Troubleshooting](troubleshooting.md).
