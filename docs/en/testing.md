# Testing and QA

[Українська версія](../uk/testing.md) · [Documentation index](README.md)

## Purpose

This document defines a reproducible local environment, automated checks, and a minimum regression checklist. Every defect should record the commit, runtime mode, browser, and test-data state.

## Prepare a QA environment

```bash
git switch dev
git pull --ff-only
git rev-parse --short HEAD
docker compose --profile frontend down --remove-orphans
docker compose --profile frontend up --build -d
docker compose ps
```

For a completely clean database, add `--volumes` to `down`. This deletes all local data and must be intentional.

Record the following for a test run:

- commit SHA;
- operating system;
- browser and version;
- desktop or mobile viewport;
- Docker or hot-reload mode;
- whether the database was clean;
- non-default ports or configuration.

## Automated frontend checks

PowerShell:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 analyze --no-pub
..\tools\flutter\flutterw.ps1 test --no-pub
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
Pop-Location
```

Run a specific file or test:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 test --no-pub test\widget_test.dart
..\tools\flutter\flutterw.ps1 test --no-pub test\widget_test.dart --plain-name "opens recipe details from recipe card"
Pop-Location
```

The suite contains repository/controller unit tests and widget tests for responsive layouts, recipe catalog, details, bookmarks, and the recipe editor.

## Backend checks

```bash
dotnet restore Chefify.sln
dotnet build Chefify.sln --configuration Release --no-restore
docker compose config
```

There is currently no separate automated backend test project. Backend regression is checked through compilation, Swagger/API scenarios, and database migration startup. Adding a backend test project is a separate engineering task.

## Quick smoke test

### Infrastructure

- `docker compose ps` shows a healthy `db` and running `api`, `frontend-web`.
- Frontend opens at `http://localhost:8088` without console startup errors.
- Swagger opens at `http://localhost:8080/swagger`.
- `GET /api/Recipes` does not return `5xx`.

### Navigation

- `/`, `/recipes`, `/recipes/create`, and `/categories` open.
- Direct refresh of `/recipes` and `/recipes/{id}` does not produce nginx 404.
- Recipe cards open details.
- Author chips open `/authors/{slug}`.
- Browser back and forward navigation keep the app functional.

### Recipe catalog

- Search finds a recipe title.
- Tag and author suggestions become tokens.
- Category, time, saved-only, and sort filters combine correctly.
- Clear search removes text and selected tokens.
- Pagination neither duplicates nor skips cards.
- API failures show error and retry state instead of demo data.

### Recipe details

- Loading, not-found, and API failure are distinct states.
- Details match the selected recipe.
- A review is prepended to the local list.
- A failed backend like rolls back and reports the error.

### Recipe editor

- Palette inserts blocks after the selected block or into the root append zone.
- Drag-and-drop works between root and nested containers.
- A parent cannot move into its own descendant.
- Inspector changes text, image, video, note, and divider settings.
- Image collage/slider and YouTube preview preserve layout.
- Resize handle changes block height.
- The creation editor does not currently persist a recipe to the backend; this is a known integration boundary.

### Responsive behavior and persistence

Test at least `320`, `390`, `768`, `1024`, and `1440` px widths.

- No horizontal overflow occurs.
- Header, docks, dialogs, and popovers remain accessible.
- Recipe and category bookmarks survive reload in the same browser profile.
- Light, dark, and system themes keep text readable.

### API and permissions

- Register → login → refresh works through Swagger.
- Public read endpoints work without a token.
- Protected endpoints without a token return `401`.
- A user cannot modify or delete another user's recipe (`403`).
- Admin endpoints reject a User token with `403`.
- File upload is tested only with a valid test S3 environment.

## Known boundaries

- The recipe creation editor is not connected to the create API.
- The frontend like endpoint is not implemented by the backend; rollback is expected.
- Not every auth, review, or file backend flow has a completed frontend UI.
- Some home content and review data are local.

Before filing a defect, confirm the scenario is not listed here. A known boundary can still be filed as a product task.

## Bug report template

```text
Title:
Commit SHA:
Environment: OS, browser/version, Docker or hot reload
Viewport:
Account/role:
Data state: clean DB or existing DB

Preconditions:
Steps to reproduce:
1.
2.
3.

Expected result:
Actual result:
Reproducibility: always / intermittent / once

Attachments:
- screenshot or video
- browser console
- failing Network request and response
- relevant docker compose logs
```

Never attach JWTs, passwords, AWS credentials, or a complete `.env` to a bug report.

## Useful logs

```bash
docker compose logs --tail=200 api
docker compose logs --tail=200 db
docker compose logs --tail=200 frontend-web
docker compose logs -f api
```

For frontend failures, include the browser Console and a Network HAR or the specific sanitized request and response.
