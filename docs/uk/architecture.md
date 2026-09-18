# Архітектура

[English version](../en/architecture.md) · [До змісту](README.md)

## Огляд

Chefify — monorepo з трьома runtime-компонентами:

```text
Browser
  └─ nginx / Flutter web
       └─ /api/* → ASP.NET Core API
                       ├─ PostgreSQL через EF Core
                       └─ AWS S3 для файлів
```

У локальному Docker-середовищі nginx, API та PostgreSQL працюють в одній Compose network. Browser звертається лише до frontend host-порту; `/api` проксіюється nginx без CORS round trip.

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
  shared/             Cross-feature models and bookmark state

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
- `data/` — API та mock repository implementations;
- `presentation/controllers/` — async collection, query і details state;
- `presentation/pages/` — route-level composition;
- `presentation/widgets/` — повторно використовуваний UI;
- `presentation/editor/` — модулі recipe editor: models, tree state, drag-and-drop, canvas, palette, inspector, media та dialogs.

Великі editor-модулі є `part` однієї Dart library, щоб зберігати приватний API між тісно пов’язаними компонентами. Це внутрішня implementation boundary, а не загальнодоступний feature API.

API URL визначається на compile time. `ApiRecipeRepository` не підмінює network/server errors mock-даними: помилки переходять у явний UI state з retry. `MockRecipeRepository` використовується лише явно, переважно у widget tests.

Bookmarks зберігаються локально через `shared_preferences`. Частина home marketing content і review seed data поки локальна й не є backend-даними.

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
- `frontend-web` — pinned Flutter build і nginx runtime, profile `frontend`;
- `frontend-preview` — nginx для локального `build/web`, profile `frontend-local-build`.

## Поточні інтеграційні межі

- Список рецептів frontend отримує з `GET /api/Recipes`.
- Recipe creation editor ще не надсилає створений документ у backend.
- Frontend like action очікує endpoint `/api/Recipes/{id}/likes`, якого поточний backend не має; UI коректно відкочує optimistic change і показує помилку.
- Reviews, auth та file flows реалізовані в backend, але не всі мають завершений frontend flow.

Ці межі потрібно враховувати під час QA, щоб не реєструвати відомий незавершений integration flow як випадковий regression.
