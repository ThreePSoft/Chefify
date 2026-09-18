# Конфігурація

[English version](../en/configuration.md) · [До змісту](README.md)

## Джерела конфігурації

- `.env.example` — шаблон для Docker Compose.
- `.env` — локальні значення; файл ігнорується Git.
- `backend/appsettings.json` — несекретні backend defaults і CORS origins.
- `backend/Properties/launchSettings.json` — локальні URL для `dotnet run`.
- `frontend/.flutter-version` — pinned Flutter SDK.
- `global.json` — .NET SDK policy.

Docker Compose автоматично читає лише `.env` у корені. Flutter отримує API URL під час компіляції через `--dart-define`.

## Змінні `.env`

| Змінна | Приклад | Використання |
| --- | --- | --- |
| `POSTGRES_DB` | `chefify_db` | Назва PostgreSQL database |
| `POSTGRES_USER` | `postgres` | Користувач PostgreSQL |
| `POSTGRES_PASSWORD` | `postgres` | Локальний пароль PostgreSQL |
| `BACKEND_HTTP_PORT` | `8080` | Host-порт API |
| `ASPNETCORE_ENVIRONMENT` | `Development` | ASP.NET Core environment; вмикає Swagger |
| `ASPNETCORE_URLS` | `http://+:8080` | URL усередині API container |
| `CONNECTION_STRING` | `Host=db;...` | EF Core connection string у Compose network |
| `JWT_KEY` | довгий secret | Підпис access token; обов’язковий |
| `JWT_ISSUER` | `ChefifyAPI` | JWT issuer |
| `JWT_AUDIENCE` | `ChefifyClient` | JWT audience |
| `S3_BUCKET_NAME` | `chefify-files` | S3 bucket; обов’язковий для старту API |
| `S3_REGION` | `eu-north-1` | AWS region; обов’язковий для старту API |
| `AWS_ACCESS_KEY_ID` | test key | Передається як `S3__AccessKey` |
| `AWS_SECRET_ACCESS_KEY` | test secret | Передається як `S3__SecretKey` |
| `S3_PRESIGNED_URL_MINUTES` | `15` | Строк presigned URL |
| `S3_MAX_UPLOAD_BYTES` | `10485760` | Ліміт upload у bytes; endpoint також має 10 MiB limit |
| `ADMIN_EMAIL` | local email | Email автоматично створеного admin |
| `ADMIN_PASSWORD` | local password | Пароль автоматично створеного admin |
| `FRONTEND_HTTP_PORT` | `8088` | Host-порт production-like frontend |
| `FRONTEND_PREVIEW_PORT` | `8089` | Host-порт local-build preview |
| `CHEFIFY_API_BASE_URL` | `/api` | Compile-time API URL Flutter web build |

## API URL у frontend

У локальному Flutter запуску default дорівнює `http://localhost:8080/api`. Рекомендовано передавати його явно:

```bash
flutter run -d chrome --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
```

Docker web build використовує `/api`; nginx проксіює цей шлях на `http://api:8080`. Не використовуй `localhost` у container-oriented web build: для браузера це буде машина користувача, а не Compose service.

## CORS

Поточні origins у `backend/appsettings.json`:

- `http://localhost:8088`;
- `http://localhost:8089`;
- `http://localhost:8090`.

При запуску Flutter на іншому порту додай origin до конфігурації backend або використовуй один із дозволених портів. Значення має містити scheme, host і port без path.

## Secrets

- Ніколи не коміть `.env`, JWT key, AWS credentials або production admin password.
- Для shared test environment використовуй окремі обмежені credentials.
- Після випадкового витоку credential недостатньо видалити його з Git: credential потрібно відкликати або rotate.
- Значення з `.env.example` є прикладами, а не production defaults.

## Перевизначення портів

Зміни `.env`, наприклад:

```dotenv
BACKEND_HTTP_PORT=8180
FRONTEND_HTTP_PORT=8188
FRONTEND_PREVIEW_PORT=8189
```

Після зміни backend host-порту локальний Flutter build має отримати відповідний `CHEFIFY_API_BASE_URL`. Container frontend із `/api` не залежить від host-порту API.
