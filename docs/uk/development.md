# Локальна розробка

[English version](../en/development.md) · [До змісту](README.md)

## Рекомендований режим

Для щоденної фронтенд-розробки найзручніший змішаний режим:

1. PostgreSQL і API працюють у Docker.
2. Flutter запускається локально з гарячим перезавантаженням (hot reload).

```bash
docker compose up -d db api
```

Після цього API доступний на `http://localhost:8080`, а Swagger — на `http://localhost:8080/swagger`.

## Flutter SDK

Проєкт використовує рівно Flutter `3.41.9`. Інсталяційні скрипти приймають тільки цю версію та можуть встановити SDK у `.flutter-sdk`.

Повний покроковий процес для Windows, Linux і macOS наведений у [гайді зі встановлення Flutter SDK](flutter-setup.md).

PowerShell:

```powershell
.\tools\flutter\setup.ps1
.\tools\flutter\flutterw.ps1 --version
```

Windows CMD:

```bat
tools\flutter\flutterw.bat --version
```

Linux або macOS:

```bash
./tools/flutter/setup.sh
FLUTTER_BIN="$(./tools/flutter/setup.sh --print-flutter-executable | tail -n 1)"
"$FLUTTER_BIN" --version
```

Порядок пошуку SDK: `CHEFIFY_FLUTTER_SDK`, збережений `.tooling/flutter-sdk-path.txt`, локальний `.flutter-sdk`, потім `flutter` у `PATH`. Невідповідна версія ігнорується.

## Запуск фронтенду з гарячим перезавантаженням

PowerShell із кореня репозиторію:

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

Порт `8089` уже дозволений поточною локальною CORS-конфігурацією API. `CHEFIFY_API_BASE_URL` задається під час компіляції: після його зміни застосунок потрібно перезапустити або перебудувати.

### Тестовий режим без бекенду

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_DATA_MODE=mock
Pop-Location
```

Звичайний запуск використовує `api` і ніколи не підміняє помилку сервера демо-даними. `mock` потрібно вказувати явно; він повертає повний локальний демо-каталог і автономну тестову авторизацію.

## Основні команди фронтенду

Виконуй їх із `frontend/` через обгортку або знайдений виконуваний файл Flutter:

```powershell
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 analyze --no-pub
..\tools\flutter\flutterw.ps1 test --no-pub
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
```

Не запускай `flutter pub upgrade` без окремого рішення команди: це змінює файл блокування залежностей і може розсинхронізувати зафіксований набір інструментів.

## Фронтенд у Docker

Production-подібна збірка з nginx:

```bash
docker compose --profile frontend up --build frontend-web api
```

nginx віддає SPA і проксіює `/api/*` до контейнера `api`. Якщо запустити лише `frontend-web`, UI відкриється, але API-запити повернуть помилку шлюзу.

Попередній перегляд уже зібраного локального `frontend/build/web`:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
Pop-Location
docker compose --profile frontend-local-build up api frontend-preview
```

Попередній перегляд доступний на `http://localhost:8089` за замовчуванням.

## Backend через Docker

Це рекомендований бекенд-процес, оскільки Compose вже передає connection string, JWT, S3 та налаштування адміністратора:

```bash
docker compose up --build db api
docker compose logs -f api
```

Після зміни C# коду образ потрібно перебудувати.

## Backend локально

`.env` автоматично читає Docker Compose, але не `dotnet run`. Для локального API спочатку запусти БД:

```bash
docker compose up -d db
```

Потім передай конфігурацію процесу. Приклад PowerShell:

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

Локальний профіль запуску слухає `http://localhost:5294`. Не зберігай справжні облікові дані в історії командної оболонки або репозиторії.

## Міграції бази даних

API виконує `Database.MigrateAsync()` під час старту. Створювати нову міграцію потрібно лише разом зі свідомою зміною моделі:

```bash
dotnet ef migrations add <MigrationName> --project backend --startup-project backend
```

Не редагуй уже застосовані файли міграцій заднім числом.
