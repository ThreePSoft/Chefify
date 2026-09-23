# Troubleshooting

[Українська версія](../uk/troubleshooting.md) · [Documentation index](README.md)

## Initial diagnostics

```bash
docker compose config
docker compose ps
docker compose logs --tail=200 db
docker compose logs --tail=200 api
docker compose logs --tail=200 frontend-web
```

`docker compose config` should complete without missing-variable messages. If resolved configuration contains unexpected empty values, inspect `.env`.

## `.env` is missing or variables are empty

Create the local root file:

```powershell
Copy-Item .env.example .env
```

Ensure its name is `.env`, not `.env.txt`. Recreate containers after changing environment values:

```bash
docker compose --profile frontend up --build --force-recreate -d
```

## Port is already in use

Change the relevant value in `.env` or stop the process using it. Example alternatives:

```dotenv
BACKEND_HTTP_PORT=8180
FRONTEND_HTTP_PORT=8188
FRONTEND_PREVIEW_PORT=8189
```

The PostgreSQL host port is currently fixed to `5432` in Compose. Stop the other PostgreSQL instance/container or change the mapping in a local Compose override.

## API exits immediately

Inspect:

```bash
docker compose logs api
```

Common causes:

- `ConnectionStrings:DefaultConnection is not configured` — missing `CONNECTION_STRING`;
- `Jwt:Key is not configured` — empty `JWT_KEY`;
- `S3:BucketName is not configured` — empty `S3_BUCKET_NAME`;
- `S3:Region is not configured` — empty `S3_REGION`;
- PostgreSQL authentication failure — `POSTGRES_*` does not match `CONNECTION_STRING`, or the volume was created with older credentials.

If database credentials changed after the volume was created, restore the previous values or intentionally reset the local volume with `docker compose down --volumes`.

## Database migration failure

The API applies migrations during startup. Avoid running incompatible branches against one volume. For a disposable QA database:

```bash
docker compose down --volumes --remove-orphans
docker compose up --build db api
```

Confirm that local data is not needed before deleting the volume.

## Frontend shows an API error or `502 Bad Gateway`

Check the API:

```bash
docker compose ps api
docker compose logs --tail=200 api
```

For container frontend, `CHEFIFY_API_BASE_URL` should be `/api`. nginx resolves the Compose service named `api`; running `frontend-web` alone results in a gateway error for API calls.

For hot reload, use the absolute URL:

```text
http://localhost:8080/api
```

After changing `--dart-define`, perform a full restart rather than only hot reload.

## `AppInspector` reports `Cannot find context with specified id`

This Flutter/Chrome DevTools message means that the inspector queried a stale JavaScript execution context after a reload, hot restart, navigation, or closing the debug tab. By itself, it is not an API or database failure.

1. Stop the current `flutter run` with `q`.
2. Close the application tab and the DevTools window created for that run.
3. Start the application again with the full command instead of hot reload:

```powershell
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_DATA_MODE=test --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
```

If the application page still crashes after a clean run, capture the first exception from `flutter run` or the browser console. Repeated `AppInspector` lines are usually a consequence of the lost context rather than the root cause.

## Browser reports a CORS error

Check the frontend origin. The backend allows `localhost:8088`, `8089`, and `8090`. Run Flutter with `--web-port 8089` or add the exact origin to `Cors:AllowedOrigins`.

`localhost` and `127.0.0.1` are different origins, as are HTTP and HTTPS.

## Flutter wrapper cannot find the SDK

```powershell
.\tools\flutter\setup.ps1
.\tools\flutter\flutterw.ps1 --version
```

Setup accepts only the version in `frontend/.flutter-version`. If the `PATH` SDK differs, select local installation into `.flutter-sdk` or set `CHEFIFY_FLUTTER_SDK` to the correct SDK root.

To clear the saved SDK location, delete `.tooling/flutter-sdk-path.txt` and run setup again.

## `pub get` or analyze uses the wrong version

Do not call global `flutter` when its version differs. Use `tools/flutter/flutterw.ps1` or the executable returned by `tools/flutter/setup.sh`.

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 --version
..\tools\flutter\flutterw.ps1 pub get --enforce-lockfile
Pop-Location
```

## Deep link returns 404

Serve production-like web through nginx with `frontend/docker/nginx.conf`. It falls back unknown non-file paths to `index.html`. A static server without SPA fallback cannot handle direct `/recipes/...` navigation.

## Stale Docker build

Try a regular rebuild first:

```bash
docker compose --profile frontend build frontend-web
docker compose --profile frontend up -d frontend-web
```

Use `--no-cache` only when the cache is suspected to be corrupt:

```bash
docker compose --profile frontend build --no-cache frontend-web
```

## S3 upload fails

Verify the test bucket, region, credentials, and required IAM object permissions. Never publish credentials in logs or bug reports. Real S3 is not required for most frontend smoke tests.

## Include this in a support request

- commit SHA (`git rev-parse --short HEAD`);
- exact startup command;
- `docker compose ps`;
- relevant sanitized logs;
- browser Console or Network error;
- custom port information without secrets.
