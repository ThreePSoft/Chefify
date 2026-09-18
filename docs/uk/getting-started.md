# Початок роботи

[English version](../en/getting-started.md) · [До змісту](README.md)

## 1. Передумови

Для рекомендованого Docker-сценарію потрібні:

- Git;
- Docker Desktop або Docker Engine;
- Docker Compose v2 (`docker compose version`);
- вільні порти `5432`, `8080` і `8088` або власні значення в `.env`.

Для локальної розробки без повної контейнеризації додатково потрібні Flutter `3.41.9`, .NET SDK 9 і Chrome або інша цільова платформа Flutter Web. Flutter можна встановити проєктним скриптом за інструкцією [«Встановлення Flutter SDK»](flutter-setup.md). PostgreSQL локально встановлювати не обов’язково: базу можна запустити окремим Docker-сервісом.

## 2. Отримання репозиторію

```bash
git clone <repository-url>
cd Chefify
git switch dev
git status --short --branch
```

## 3. Локальна конфігурація

PowerShell:

```powershell
Copy-Item .env.example .env
```

Bash:

```bash
cp .env.example .env
```

`.env` ігнорується Git. Не додавай у нього облікові дані виробничого середовища. Початкові значення підходять для локального старту, але файлові операції S3 вимагатимуть справжніх тестових облікових даних AWS і тестового бакета.

Щонайменше перевір:

- `POSTGRES_*` і `CONNECTION_STRING` узгоджені;
- `JWT_KEY` містить довгий локальний секрет;
- `ADMIN_EMAIL` та `ADMIN_PASSWORD` безпечні для середовища;
- порти не зайняті іншими програмами.

Повний опис міститься в [конфігурації](configuration.md).

## 4. Запуск повного стеку

```bash
docker compose --profile frontend up --build
```

Для запуску у фоні:

```bash
docker compose --profile frontend up --build -d
```

Compose запускає PostgreSQL, очікує його healthcheck, запускає API, збирає Flutter web і віддає його через nginx.

| Сервіс | Адреса | Призначення |
| --- | --- | --- |
| Frontend | <http://localhost:8088> | Flutter web застосунок |
| API | <http://localhost:8080> | ASP.NET Core API |
| Swagger | <http://localhost:8080/swagger> | API-документація у Development |
| PostgreSQL | `localhost:5432` | Локальна база даних |

Під час першого старту API автоматично застосовує EF Core migrations. Якщо `ADMIN_EMAIL` і `ADMIN_PASSWORD` задані, створюється локальний адміністратор, якщо користувача з таким email ще немає.

## 5. Перевірка запуску

```bash
docker compose ps
docker compose logs --tail=100 api
docker compose logs --tail=100 frontend-web
```

Очікуваний стан:

- `db` має статус healthy;
- `api` не завершується через помилку конфігурації;
- `frontend-web` слухає вибраний HTTP-порт;
- `GET http://localhost:8080/api/Recipes` повертає JSON або порожній масив;
- прямий перехід на <http://localhost:8088/recipes> відкриває SPA, а не nginx 404.

## 6. Зупинка і перезапуск

```bash
docker compose --profile frontend down --remove-orphans
docker compose --profile frontend up --build -d
```

Звичайний `down` не видаляє дані PostgreSQL.

## 7. Повне скидання локальних даних

Наступна команда видаляє Docker volume з локальною БД. Не використовуй її, якщо дані потрібно зберегти.

```bash
docker compose --profile frontend down --volumes --remove-orphans
docker compose --profile frontend up --build -d
```

## 8. Наступні кроки

- Розробнику: [локальна розробка](development.md).
- Тестувальнику: [тестування і QA](testing.md).
- Для роботи з API: [API](api.md).
- Якщо щось не стартує: [вирішення проблем](troubleshooting.md).
