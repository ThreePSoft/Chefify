# Архітектура

[English version](../en/architecture.md) · [До змісту](README.md)

## Огляд

Chefify — монорепозиторій із трьома компонентами, що виконуються:

```text
Browser
  └─ nginx / Flutter web
       └─ /api/* → ASP.NET Core API
                       ├─ PostgreSQL через EF Core
                       └─ AWS S3 для файлів
```

У локальному Docker-середовищі nginx, API та PostgreSQL працюють в одній мережі Compose. Браузер звертається лише до зовнішнього порту фронтенду; nginx проксіює `/api` без окремого CORS-запиту.

## Структура репозиторію

```text
backend/
  Controllers/       HTTP endpoints та authorization attributes
  Data/              DbContext, migrations startup, admin seed
  Dto/               Transport contracts
  Migrations/        EF Core schema history
  Models/             Database entities
  Options/            Strongly typed configuration
  Services/           Application and integration logic

frontend/lib/
  app/                App composition, theme, route generation
  core/               Shared constants, images, localization, widgets
  features/           Feature-oriented code
  shared/             Спільні моделі та стан закладок

docs/
  uk/                 Українська документація
  en/                 English documentation

tools/flutter/        Flutter version discovery/install wrappers
```

## Frontend

Frontend — Flutter web application із path URL strategy. Основні маршрути:

- `/`;
- `/recipes`;
- `/recipes/create`;
- `/recipes/:id`;
- `/categories`;
- `/authors/:slug`.

`frontend/lib/features/recipes` використовує шарування:

- `domain/` — repository contract і route arguments;
- `data/` — реалізації репозиторіїв для API та тестових даних;
- `presentation/controllers/` — стан асинхронних колекцій, запитів і деталей;
- `presentation/pages/` — компонування сторінок маршрутів;
- `presentation/widgets/` — повторно використовуваний інтерфейс;
- `presentation/editor/` — модулі редактора рецептів: моделі, дерево стану, перетягування, полотно, палітра, інспектор, медіа та діалоги.

Великі модулі редактора є `part` однієї бібліотеки Dart, щоб зберігати приватний API між тісно пов’язаними компонентами. Це внутрішня межа реалізації, а не загальнодоступний API функціональності.

URL API визначається під час компіляції. `ApiRecipeRepository` не підмінює мережеві або серверні помилки тестовими даними: інтерфейс показує окремий стан помилки та повторну спробу. `MockRecipeRepository` використовується лише явно, переважно у віджет-тестах.

Закладки зберігаються локально через `shared_preferences`. Частина вмісту головної сторінки та початкових даних відгуків поки локальна й не надходить із бекенду.

## Backend

Backend — ASP.NET Core 9 Web API:

- controllers визначають HTTP routing і role requirements;
- services містять query/command/auth/file logic;
- EF Core з Npgsql працює з PostgreSQL;
- migrations застосовуються автоматично у `DatabaseInitializer`;
- JWT Bearer використовується для ролей `User` і `Admin`;
- `S3FileStorageService` працює з AWS S3 та presigned URLs.

Swagger доступний лише коли `ASPNETCORE_ENVIRONMENT=Development`.

## Контейнери

- `db` — `postgres:17` із persistent volume `postgres_data`;
- `api` — multi-stage .NET 9 image;
- `frontend-web` — збірка на зафіксованій версії Flutter та nginx, профіль `frontend`;
- `frontend-preview` — nginx для локального `build/web`, профіль `frontend-local-build`.

## Поточні інтеграційні межі

- Список рецептів фронтенд отримує з `GET /api/Recipes`.
- Редактор створення рецепта ще не надсилає створений документ у бекенд.
- Дія «подобається» очікує кінцеву точку `/api/Recipes/{id}/likes`, якої поточний бекенд не має; інтерфейс коректно відкочує оптимістичну зміну й показує помилку.
- Відгуки, автентифікація та файлові операції реалізовані в бекенді, але не всі мають завершені сценарії у фронтенді.

Ці межі потрібно враховувати під час QA, щоб не реєструвати відомий незавершений інтеграційний сценарій як випадкову регресію.
