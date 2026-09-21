# Configuration

[Українська версія](../uk/configuration.md) · [Documentation index](README.md)

## Configuration sources

- `.env.example` — Docker Compose template.
- `.env` — local values; ignored by Git.
- `backend/appsettings.json` — non-secret backend defaults and CORS origins.
- `backend/Properties/launchSettings.json` — local `dotnet run` URLs.
- `frontend/.flutter-version` — pinned Flutter SDK.
- `global.json` — .NET SDK policy.

Docker Compose automatically reads only the root `.env`. Flutter receives its API URL at compile time through `--dart-define`.

## `.env` variables

| Variable | Example | Purpose |
| --- | --- | --- |
| `POSTGRES_DB` | `chefify_db` | PostgreSQL database name |
| `POSTGRES_USER` | `postgres` | PostgreSQL user |
| `POSTGRES_PASSWORD` | `postgres` | Local PostgreSQL password |
| `BACKEND_HTTP_PORT` | `8080` | API host port |
| `ASPNETCORE_ENVIRONMENT` | `Development` | ASP.NET environment; enables Swagger |
| `ASPNETCORE_URLS` | `http://+:8080` | URL inside the API container |
| `CONNECTION_STRING` | `Host=db;...` | EF Core connection string in Compose network |
| `JWT_KEY` | long secret | Access-token signing key; required |
| `JWT_ISSUER` | `ChefifyAPI` | JWT issuer |
| `JWT_AUDIENCE` | `ChefifyClient` | JWT audience |
| `S3_BUCKET_NAME` | `chefify-files` | S3 bucket; required for API startup |
| `S3_REGION` | `eu-north-1` | AWS region; required for API startup |
| `AWS_ACCESS_KEY_ID` | test key | Passed to the API as `S3__AccessKey` |
| `AWS_SECRET_ACCESS_KEY` | test secret | Passed as `S3__SecretKey` |
| `S3_PRESIGNED_URL_MINUTES` | `15` | Presigned URL lifetime |
| `S3_MAX_UPLOAD_BYTES` | `10485760` | Upload limit in bytes; endpoint limit is also 10 MiB |
| `ADMIN_EMAIL` | local email | Automatically seeded administrator email |
| `ADMIN_PASSWORD` | local password | Automatically seeded administrator password |
| `FRONTEND_HTTP_PORT` | `8088` | Production-like frontend host port |
| `FRONTEND_PREVIEW_PORT` | `8089` | Local-build preview host port |
| `CHEFIFY_API_BASE_URL` | `/api` | Compile-time Flutter web API URL |
| `CHEFIFY_DATA_MODE` | `api` | Frontend data source: `api` or `mock` |

## Frontend API URL

Local Flutter defaults to `http://localhost:8080/api`; passing it explicitly is recommended:

```bash
flutter run -d chrome --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
```

The Docker web build uses `/api`, which nginx proxies to `http://api:8080`. Do not use `localhost` in a container-oriented web build: the browser would interpret it as the user's machine, not the Compose service.

## Frontend data mode

`CHEFIFY_DATA_MODE=api` is the default: recipes, authentication, likes, and other server-owned data come only from the API. An API failure is displayed as an error; mock records, generated reviews and counters, and demo-catalog suggestions are never substituted.

Explicitly enable `mock` to test the interface without a backend:

```powershell
cd frontend
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_DATA_MODE=mock
```

This mode enables the complete demo catalog, homepage demo sections, local demo reviews, and standalone authentication. Any valid email and password accepted by the form can be used to sign in. The value is compile-time configuration, so fully restart the app after changing modes.

## CORS

Current origins in `backend/appsettings.json`:

- `http://localhost:8088`;
- `http://localhost:8089`;
- `http://localhost:8090`.

When Flutter uses another port, add the origin to backend configuration or use an allowed port. An origin includes scheme, host, and port without a path.

## Secrets

- Never commit `.env`, JWT keys, AWS credentials, or production administrator passwords.
- Use separate restricted credentials for a shared test environment.
- If a credential leaks, deleting it from Git is insufficient: revoke or rotate it.
- `.env.example` values are examples, not production defaults.

## Override ports

Edit `.env`, for example:

```dotenv
BACKEND_HTTP_PORT=8180
FRONTEND_HTTP_PORT=8188
FRONTEND_PREVIEW_PORT=8189
```

After changing the backend host port, a local Flutter build needs the matching `CHEFIFY_API_BASE_URL`. A container frontend using `/api` does not depend on the API host port.
