# Architecture

[Українська версія](../uk/architecture.md) · [Documentation index](README.md)

## Overview

Chefify is a monorepo with three runtime components:

```text
Browser
  └─ nginx / Flutter web
       └─ /api/* → ASP.NET Core API
                       ├─ PostgreSQL through EF Core
                       └─ AWS S3 for files
```

In local Docker, nginx, the API, and PostgreSQL share a Compose network. The browser calls the frontend host port, and nginx proxies `/api` without a CORS round trip.

## Repository layout

```text
backend/
  Controllers/       HTTP endpoints and authorization attributes
  Data/              DbContext, startup migrations, admin seed
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
  uk/                 Ukrainian documentation
  en/                 English documentation

tools/flutter/        Flutter discovery/install wrappers
```

## Frontend

The frontend is a Flutter web application with path URL strategy. Main routes:

- `/`;
- `/recipes`;
- `/recipes/create`;
- `/recipes/:id`;
- `/categories`;
- `/authors/:slug`.

`frontend/lib/features/recipes` uses these layers:

- `domain/` — repository contract and route arguments;
- `data/` — API and mock repository implementations;
- `presentation/controllers/` — async collection, query, and details state;
- `presentation/pages/` — route-level composition;
- `presentation/widgets/` — reusable UI;
- `presentation/editor/` — recipe editor models, tree state, drag-and-drop, canvas, palette, inspector, media, and dialogs.

Large editor modules are `part` files of one Dart library, preserving a private API between tightly coupled components. This is an internal implementation boundary, not a public feature API.

The API URL is a compile-time value. `ApiRecipeRepository` does not replace network or server failures with mock data: failures become explicit UI state with retry. `MockRecipeRepository` is opt-in and mainly used in widget tests.

Bookmarks are stored locally through `shared_preferences`. Some home marketing content and seeded review data remain local rather than backend-provided.

## Backend

The backend is an ASP.NET Core 9 Web API:

- controllers define HTTP routes and role requirements;
- services contain query, command, auth, and file logic;
- EF Core with Npgsql accesses PostgreSQL;
- `DatabaseInitializer` applies migrations automatically;
- JWT Bearer authentication provides `User` and `Admin` roles;
- `S3FileStorageService` integrates AWS S3 and presigned URLs.

Swagger is available only when `ASPNETCORE_ENVIRONMENT=Development`.

## Containers

- `db` — `postgres:17` with persistent `postgres_data` volume;
- `api` — multi-stage .NET 9 image;
- `frontend-web` — pinned Flutter build and nginx runtime, profile `frontend`;
- `frontend-preview` — nginx for local `build/web`, profile `frontend-local-build`.

## Current integration boundaries

- Frontend recipe lists come from `GET /api/Recipes`.
- The recipe creation editor does not yet submit its document to the backend.
- The frontend like action expects `/api/Recipes/{id}/likes`, which the current backend does not provide. The UI rolls back the optimistic change and reports the failure.
- Reviews, authentication, and file flows exist in the backend, but not all have completed frontend flows.

QA should account for these boundaries instead of treating a known unfinished integration flow as an incidental regression.
