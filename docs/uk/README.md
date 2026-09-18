# Документація Chefify

[English version](../en/README.md) · [Головний README](../../README.md)

Ця документація призначена для розробників, тестувальників і нових учасників команди.

## Розділи

- [Початок роботи](getting-started.md) — вимоги, перший запуск, адреси сервісів і скидання локального середовища.
- [Локальна розробка](development.md) — Flutter, backend, робочі команди та режими запуску.
- [Конфігурація](configuration.md) — змінні середовища, порти, secrets, API URL, CORS і S3.
- [Архітектура](architecture.md) — структура репозиторію, frontend-шари, backend і потоки даних.
- [API](api.md) — групи endpoint-ів, авторизація, Swagger та обмеження.
- [Тестування і QA](testing.md) — автоматизовані перевірки, smoke checklist і оформлення дефектів.
- [Вирішення проблем](troubleshooting.md) — типові проблеми Docker, Flutter, API, БД і мережі.

## Найкоротший запуск

```powershell
Copy-Item .env.example .env
docker compose --profile frontend up --build
```

Відкрити <http://localhost:8088>. Повна інструкція наведена в [«Початок роботи»](getting-started.md).

## Правило актуальності

Документація має описувати фактичний стан `dev`. Зміна команд, портів, конфігурації, API-контракту або структури проєкту повинна супроводжуватися змінами у відповідних файлах `docs/uk` і `docs/en`.
