# Конфігурація

[English version](../en/configuration.md) · [До змісту](README.md)

## Джерела конфігурації

- `.env.example` — шаблон для Docker Compose.
- `.env` — локальні значення; файл ігнорується Git.
- `backend/appsettings.json` — несекретні значення бекенду за замовчуванням і дозволені джерела CORS.
- `backend/Properties/launchSettings.json` — локальні URL для `dotnet run`.
- `frontend/.flutter-version` — зафіксована версія Flutter SDK.
- `global.json` — .NET SDK policy.

Docker Compose автоматично читає лише `.env` у корені. Flutter отримує API URL під час компіляції через `--dart-define`.

## Змінні `.env`

| Змінна | Приклад | Використання |
| --- | --- | --- |
| `POSTGRES_DB` | `chefify_db` | Назва PostgreSQL database |
| `POSTGRES_USER` | `postgres` | Користувач PostgreSQL |
| `POSTGRES_PASSWORD` | `postgres` | Локальний пароль PostgreSQL |
| `BACKEND_HTTP_PORT` | `8080` | Host-порт API |
| `ASPNETCORE_ENVIRONMENT` | `Development` | Середовище ASP.NET Core; вмикає Swagger |
| `ASPNETCORE_URLS` | `http://+:8080` | URL усередині API-контейнера |
| `CONNECTION_STRING` | `Host=db;...` | Рядок підключення EF Core у мережі Compose |
| `JWT_KEY` | довгий secret | Підпис access token; обов’язковий |
| `JWT_ISSUER` | `ChefifyAPI` | JWT issuer |
| `JWT_AUDIENCE` | `ChefifyClient` | JWT audience |
| `S3_BUCKET_NAME` | `chefify-files` | Бакет S3; обов’язковий для старту API |
| `S3_REGION` | `eu-north-1` | AWS region; обов’язковий для старту API |
| `AWS_ACCESS_KEY_ID` | тестовий ключ | Передається як `S3__AccessKey` |
| `AWS_SECRET_ACCESS_KEY` | тестовий секрет | Передається як `S3__SecretKey` |
| `S3_PRESIGNED_URL_MINUTES` | `15` | Строк presigned URL |
| `S3_MAX_UPLOAD_BYTES` | `10485760` | Ліміт завантаження у байтах; кінцева точка також обмежена 10 MiB |
| `ADMIN_EMAIL` | local email | Email автоматично створеного адміністратора |
| `ADMIN_PASSWORD` | local password | Пароль автоматично створеного адміністратора |
| `FRONTEND_HTTP_PORT` | `8088` | Зовнішній порт фронтенду, подібного до виробничого |
| `FRONTEND_PREVIEW_PORT` | `8089` | Host-порт preview локальної збірки |
| `CHEFIFY_API_BASE_URL` | `/api` | Compile-time API URL Flutter web build |
| `CHEFIFY_DATA_MODE` | `api` | Джерело даних фронтенду: `api` або `mock` |

## API URL у фронтенді

У локальному Flutter-запуску значення за замовчуванням дорівнює `http://localhost:8080/api`. Рекомендовано передавати його явно:

```bash
flutter run -d chrome --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
```

Docker web build використовує `/api`; nginx проксіює цей шлях на `http://api:8080`. Не використовуй `localhost` у контейнерній web-збірці: для браузера це буде машина користувача, а не Compose-сервіс.

## Режим даних фронтенду

За замовчуванням `CHEFIFY_DATA_MODE=api`: рецепти, авторизація, лайки та інші серверні дані надходять лише з API. Помилка API відображається як помилка; мокові записи, згенеровані відгуки, лічильники й підказки з демо-каталогу не підставляються.

Для ізольованої перевірки інтерфейсу без бекенду явно ввімкни `mock`:

```powershell
cd frontend
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_DATA_MODE=mock
```

У цьому режимі доступні повний демо-каталог, блоки домашньої сторінки, локальні демо-відгуки та автономна авторизація. Для входу підходять будь-які валідні email і пароль, що проходять перевірку форми. Значення задається під час компіляції, тому після зміни режиму застосунок потрібно повністю перезапустити.

## CORS

Поточні дозволені джерела у `backend/appsettings.json`:

- `http://localhost:8088`;
- `http://localhost:8089`;
- `http://localhost:8090`.

При запуску Flutter на іншому порту додай джерело до конфігурації бекенду або використовуй один із дозволених портів. Значення має містити протокол, хост і порт без шляху.

## Secrets

- Ніколи не коміть `.env`, ключ JWT, облікові дані AWS або пароль адміністратора виробничого середовища.
- Для спільного тестового середовища використовуй окремі облікові дані з мінімальними правами.
- Після випадкового витоку credential недостатньо видалити його з Git: credential потрібно відкликати або rotate.
- Значення з `.env.example` є прикладами, а не налаштуваннями виробничого середовища.

## Перевизначення портів

Зміни `.env`, наприклад:

```dotenv
BACKEND_HTTP_PORT=8180
FRONTEND_HTTP_PORT=8188
FRONTEND_PREVIEW_PORT=8189
```

Після зміни зовнішнього порту бекенду локальна Flutter-збірка має отримати відповідний `CHEFIFY_API_BASE_URL`. Контейнерний фронтенд із `/api` не залежить від зовнішнього порту API.
