# Local development

[Українська версія](../uk/development.md) · [Documentation index](README.md)

## Recommended workflow

The most convenient daily frontend workflow is hybrid:

1. PostgreSQL and the API run in Docker.
2. Flutter runs locally with hot reload.

```bash
docker compose up -d db api
```

The API is then available at `http://localhost:8080`, with Swagger at `http://localhost:8080/swagger`.

## Flutter SDK

The project uses exactly Flutter `3.41.9`. Setup scripts accept only this version and can install it into `.flutter-sdk`.

PowerShell:

```powershell
.\tools\flutter\setup.ps1
.\tools\flutter\flutterw.ps1 --version
```

Windows CMD:

```bat
tools\flutter\flutterw.bat --version
```

Linux or macOS:

```bash
./tools/flutter/setup.sh
FLUTTER_BIN="$(./tools/flutter/setup.sh --print-flutter-executable | tail -n 1)"
"$FLUTTER_BIN" --version
```

SDK lookup order is `CHEFIFY_FLUTTER_SDK`, saved `.tooling/flutter-sdk-path.txt`, local `.flutter-sdk`, then `flutter` in `PATH`. An SDK with the wrong version is ignored.

## Run frontend with hot reload

PowerShell from the repository root:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
Pop-Location
```

Bash:

```bash
FLUTTER_BIN="$(./tools/flutter/setup.sh --print-flutter-executable | tail -n 1)"
cd frontend
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" run -d chrome --web-port 8089 \
  --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
```

Port `8089` is already allowed by the current local API CORS configuration. `CHEFIFY_API_BASE_URL` is a compile-time value; restart or rebuild the application after changing it.

## Common frontend commands

Run these from `frontend/` through the wrapper or resolved Flutter executable:

```powershell
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 analyze --no-pub
..\tools\flutter\flutterw.ps1 test --no-pub
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
```

Do not run `flutter pub upgrade` without a separate team decision. It changes the lockfile and can desynchronize the pinned toolchain.

## Docker frontend

Production-like build served by nginx:

```bash
docker compose --profile frontend up --build frontend-web api
```

nginx serves the SPA and proxies `/api/*` to the `api` container. Starting only `frontend-web` serves the UI, but API requests return a gateway error.

Preview a locally generated `frontend/build/web`:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
Pop-Location
docker compose --profile frontend-local-build up api frontend-preview
```

The preview uses `http://localhost:8089` by default.

## Backend through Docker

This is the recommended backend workflow because Compose passes connection, JWT, S3, and administrator settings:

```bash
docker compose up --build db api
docker compose logs -f api
```

Rebuild the image after changing C# code.

## Run backend locally

Docker Compose reads `.env`; `dotnet run` does not. Start the database first:

```bash
docker compose up -d db
```

Then configure the process. PowerShell example:

```powershell
$env:ConnectionStrings__DefaultConnection='Host=localhost;Port=5432;Database=chefify_db;Username=postgres;Password=postgres'
$env:Jwt__Key='change_this_to_a_long_random_secret_at_least_32_chars'
$env:Jwt__Issuer='ChefifyAPI'
$env:Jwt__Audience='ChefifyClient'
$env:S3__BucketName='chefify-files'
$env:S3__Region='eu-north-1'
$env:S3__AccessKey='your-test-access-key'
$env:S3__SecretKey='your-test-secret-key'
$env:ADMIN_EMAIL='admin@chefify.local'
$env:ADMIN_PASSWORD='local-admin-password'
dotnet restore .\backend\backend.csproj
dotnet run --project .\backend\backend.csproj --launch-profile http
```

The local launch profile listens on `http://localhost:5294`. Never store real credentials in shell history or the repository.

## Database migrations

The API runs `Database.MigrateAsync()` during startup. Create a migration only with an intentional model change:

```bash
dotnet ef migrations add <MigrationName> --project backend --startup-project backend
```

Do not edit an already applied migration retroactively.
