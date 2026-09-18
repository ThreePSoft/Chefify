# Тестування і QA

[English version](../en/testing.md) · [До змісту](README.md)

## Мета

Цей документ описує відтворюване локальне середовище, автоматизовані перевірки та мінімальний перелік регресійних перевірок. Для кожного дефекту фіксуй коміт, режим запуску, браузер і стан тестових даних.

## Підготовка QA-середовища

```bash
git switch dev
git pull --ff-only
git rev-parse --short HEAD
docker compose --profile frontend down --remove-orphans
docker compose --profile frontend up --build -d
docker compose ps
```

Для повністю чистої БД додай `--volumes` до `down`. Це видаляє всі локальні дані, тому роби це лише свідомо.

Збережи у звіті про тестовий прогін:

- commit SHA;
- operating system;
- браузер і версію;
- розмір області перегляду для комп’ютера або мобільного пристрою;
- Docker або режим гарячого перезавантаження;
- чи використовувалася чиста БД;
- нестандартні значення портів і конфігурації.

## Автоматизовані перевірки фронтенду

PowerShell:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 analyze --no-pub
..\tools\flutter\flutterw.ps1 test --no-pub
..\tools\flutter\flutterw.ps1 build web --release --no-pub --dart-define=CHEFIFY_API_BASE_URL=/api
Pop-Location
```

Запуск окремого файла або тесту:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 test --no-pub test\features\recipes\presentation\recipe_details_widget_test.dart
..\tools\flutter\flutterw.ps1 test --no-pub test\features\recipes\presentation\recipe_details_widget_test.dart --plain-name "opens recipe details from recipe card"
Pop-Location
```

Набір організовано за відповідальністю:

- `test/core` — тести slug, SEO та еталонних зображень;
- `test/features/recipes/data` — модульні тести репозиторіїв;
- `test/features/recipes/presentation/controllers` — модульні тести контролерів;
- `test/features/recipes/presentation` — віджет-тести каталогу, деталей і редактора;
- `test/app` та `test/shared` — віджет-тести оболонки застосунку й закладок;
- `integration_test` — браузерна перевірка основного сценарію каталогу.

Оновлення та перевірка еталонного зображення брендового знака:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 test --no-pub --update-goldens test\core\widgets\chefify_brand_mark_golden_test.dart
..\tools\flutter\flutterw.ps1 test --no-pub test\core\widgets\chefify_brand_mark_golden_test.dart
Pop-Location
```

Для браузерного інтеграційного тесту потрібен сумісний ChromeDriver на порту `4444`. Після його запуску:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 drive -d chrome --driver test_driver/integration_test.dart --target integration_test/app_smoke_test.dart --no-pub
Pop-Location
```

`.github/workflows/frontend.yml` запускає форматування, статичний аналіз, модульні, віджет- і golden-тести, release web build та браузерний integration smoke test для frontend pull request-ів у `dev`.

## Backend-перевірки

```bash
dotnet restore Chefify.sln
dotnet build Chefify.sln --configuration Release --no-restore
docker compose config
```

Окремого проєкту автоматизованих тестів бекенду наразі немає. Регресію бекенду перевіряють через збірку, сценарії Swagger/API та застосування міграцій під час запуску. Додавання такого тестового проєкту є окремою технічною задачею.

## Швидка перевірка основних сценаріїв

### Інфраструктура

- `docker compose ps` показує справну `db` і запущені `api`, `frontend-web`.
- Фронтенд відкривається на `http://localhost:8088` без помилок запуску в консолі браузера.
- Swagger відкривається на `http://localhost:8080/swagger`.
- `GET /api/Recipes` не повертає `5xx`.

### Навігація

- `/`, `/recipes`, `/recipes/create`, `/categories` відкриваються.
- Пряме оновлення `/recipes` і `/recipes/{id}` не дає nginx 404.
- Картка рецепта відкриває його деталі.
- Елемент автора відкриває `/authors/{slug}`.
- Навігація браузера назад і вперед не ламає сторінку.

### Каталог рецептів

- Пошук знаходить рецепт за назвою.
- Підказки тегів і авторів перетворюються на токени.
- Фільтри категорії, часу, збережених рецептів і сортування правильно комбінуються.
- Очищення пошуку видаляє текст і вибрані токени.
- Пагінація не дублює і не пропускає картки.
- Помилка API показує стан помилки та повторну спробу, а не демонстраційні дані.

### Деталі рецепта

- Завантаження, відсутній рецепт і помилка API мають різні стани.
- Деталі відповідають вибраному рецепту.
- Відгук додається на початок локального списку.
- Позначка «подобається» при помилці бекенду відкочується та показує повідомлення.

### Редактор рецептів

- Палітра додає блоки після вибраного блока або в кореневу зону додавання.
- Перетягування працює між коренем і вкладеними контейнерами.
- Неможливо перемістити батьківський елемент у власного нащадка.
- Інспектор змінює параметри тексту, зображення, відео, примітки та роздільника.
- Колаж, слайдер зображень і попередній перегляд YouTube не ламають верстку.
- Маркер зміни розміру змінює висоту блока.
- Редактор створення наразі не зберігає рецепт у бекенд — це відома межа інтеграції.

### Адаптивність і збереження стану

Перевір щонайменше ширини `320`, `390`, `768`, `1024`, `1440` px.

- Немає горизонтального переповнення.
- Заголовок, панелі, діалоги та спливні елементи залишаються доступними.
- Закладки рецептів і категорій зберігаються після перезавантаження в тому самому профілі браузера.
- Обрана мова інтерфейсу та світла/темна тема зберігаються після перезавантаження в тому самому профілі браузера.
- Англійський, український та іспанський текст інтерфейсу не переповнює компоненти на підтримуваних ширинах.

### API і права доступу

- Зареєструйся через `/register`, перевір автоматичний вхід і відображення імені, email та ролі на `/profile`.
- Вийди з `/profile`, онови сторінку й переконайся, що повернувся гостьовий header.
- Неправильні облікові дані та повторний email показують локалізовану помилку у формі без втрати введених значень.
- Реєстрація → вхід → оновлення токена працюють через Swagger.
- Публічні кінцеві точки читання доступні без токена.
- Захищена кінцева точка без токена повертає `401`.
- Користувач не може змінити або видалити чужий рецепт (`403`).
- Адміністративна кінцева точка з токеном користувача повертає `403`.
- Завантаження файлів перевіряється лише з чинним тестовим середовищем S3.

## Відомі межі поточної версії

- Редактор створення рецептів не підключений до API створення.
- Кінцева точка «подобається» ще не реалізована в бекенді; очікується відкат зміни.
- Автоматичне оновлення token-ів, віддалене редагування профілю, відновлення пароля та завантаження аватара ще не мають завершеного frontend UI.
- Надсилання відгуків змінює лише локальний стан frontend, а файлові операції не підключені до UI.
- Частина вмісту головної сторінки й даних відгуків локальна.

Перед створенням звіту про дефект переконайся, що сценарій не входить до цього списку. Відомі межі все одно можна оформлювати як продуктову задачу.

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

Не додавай JWT, паролі, облікові дані AWS або повний `.env` до звіту про дефект.

## Корисні логи

```bash
docker compose logs --tail=200 api
docker compose logs --tail=200 db
docker compose logs --tail=200 frontend-web
docker compose logs -f api
```

Для помилки фронтенду додай консоль браузера й Network HAR або конкретні очищені від секретів запит і відповідь.
