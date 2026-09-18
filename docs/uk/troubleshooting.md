# Вирішення проблем

[English version](../en/troubleshooting.md) · [До змісту](README.md)

## Початкова діагностика

```bash
docker compose config
docker compose ps
docker compose logs --tail=200 db
docker compose logs --tail=200 api
docker compose logs --tail=200 frontend-web
```

`docker compose config` має виконуватися без повідомлень про відсутні змінні. Якщо конфігурація містить неочікувані порожні значення, перевір `.env`.

## `.env` не знайдено або змінні порожні

Створи локальний файл у корені репозиторію:

```powershell
Copy-Item .env.example .env
```

Перевір, що він називається саме `.env`, а не `.env.txt`. Після зміни змінних середовища контейнери потрібно створити заново:

```bash
docker compose --profile frontend up --build --force-recreate -d
```

## Порт зайнятий

Перевір порт у `.env` або знайди процес, що його використовує. Приклад альтернативних значень:

```dotenv
BACKEND_HTTP_PORT=8180
FRONTEND_HTTP_PORT=8188
FRONTEND_PREVIEW_PORT=8189
```

Зовнішній порт PostgreSQL наразі зафіксований у Compose як `5432`. Зупини інший PostgreSQL або контейнер чи зміни зіставлення портів у локальній конфігурації перевизначення Compose.

## API завершується одразу

Переглянь:

```bash
docker compose logs api
```

Типові причини:

- `ConnectionStrings:DefaultConnection is not configured` — відсутній `CONNECTION_STRING`;
- `Jwt:Key is not configured` — порожній `JWT_KEY`;
- `S3:BucketName is not configured` — порожній `S3_BUCKET_NAME`;
- `S3:Region is not configured` — порожній `S3_REGION`;
- помилка автентифікації PostgreSQL — `POSTGRES_*` не відповідають `CONNECTION_STRING` або том створено зі старими обліковими даними.

Якщо облікові дані БД були змінені після створення тому, поверни старі значення або свідомо скинь локальний том через `docker compose down --volumes`.

## Помилка міграції бази даних

API застосовує міграції під час запуску. Не запускай кілька несумісних гілок на одному томі. Для тимчасової бази даних QA:

```bash
docker compose down --volumes --remove-orphans
docker compose up --build db api
```

Перед видаленням тому переконайся, що локальні дані не потрібні.

## Фронтенд показує помилку API або `502 Bad Gateway`

Перевір API:

```bash
docker compose ps api
docker compose logs --tail=200 api
```

У контейнерному фронтенді `CHEFIFY_API_BASE_URL` має бути `/api`. nginx шукає сервіс Compose із назвою `api`; запуск одного `frontend-web` без API дає помилку шлюзу.

Для гарячого перезавантаження використовуй абсолютний URL:

```text
http://localhost:8080/api
```

Після зміни `--dart-define` виконай повний перезапуск, а не лише гаряче перезавантаження.

## Помилка CORS у браузері

Перевір джерело фронтенду. Бекенд дозволяє `localhost:8088`, `8089`, `8090`. Запусти Flutter із `--web-port 8089` або додай точне джерело до `Cors:AllowedOrigins`.

`localhost` і `127.0.0.1` є різними origins. Так само відрізняються HTTP та HTTPS.

## Flutter-обгортка не знаходить SDK

```powershell
.\tools\flutter\setup.ps1
.\tools\flutter\flutterw.ps1 --version
```

Інсталяційний скрипт приймає лише версію з `frontend/.flutter-version`. Якщо `flutter` у `PATH` має іншу версію, вибери локальне встановлення в `.flutter-sdk` або задай `CHEFIFY_FLUTTER_SDK` на правильний кореневий каталог SDK.

Скинути збережений локальний шлях можна видаленням `.tooling/flutter-sdk-path.txt`, після чого повторити налаштування.

## `pub get` або analyze використовує не ту версію

Не запускай глобальний `flutter`, якщо його версія відрізняється. Використовуй `tools/flutter/flutterw.ps1` або виконуваний файл, повернений `tools/flutter/setup.sh`.

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 --version
..\tools\flutter\flutterw.ps1 pub get --enforce-lockfile
Pop-Location
```

## Deep link повертає 404

Збірку, подібну до виробничої, потрібно відкривати через nginx із `frontend/docker/nginx.conf`. Для невідомих шляхів, які не є файлами, він повертає `index.html`. Статичний сервер без резервного маршруту SPA не підтримує прямі переходи на `/recipes/...`.

## Застарілий Docker build

Спочатку спробуй звичайний rebuild:

```bash
docker compose --profile frontend build frontend-web
docker compose --profile frontend up -d frontend-web
```

`--no-cache` використовуй лише коли є підозра на пошкоджений кеш:

```bash
docker compose --profile frontend build --no-cache frontend-web
```

## S3 upload не працює

Переконайся, що використовуються тестові бакет, регіон та облікові дані, а IAM дозволяє потрібні операції з об’єктами. Не публікуй облікові дані в логах або звіті про дефект. Для більшості базових перевірок фронтенду справжній S3 не потрібен.

## Що додати до запиту про допомогу

- commit SHA (`git rev-parse --short HEAD`);
- точна команда запуску;
- `docker compose ps`;
- релевантні логи, очищені від секретів;
- помилка з Console або Network браузера;
- інформація про нестандартні порти без секретів.
