# API

[English version](../en/api.md) · [До змісту](README.md)

## Базові адреси

- Docker API: `http://localhost:8080`
- Локальний `dotnet run --launch-profile http`: `http://localhost:5294`
- Swagger у Development: `/swagger`
- API prefix: `/api`

Swagger є джерелом актуальних request/response schemas. Цей файл описує навігацію і правила доступу, а не дублює всі DTO.

## Авторизація

Захищені кінцеві точки очікують заголовок:

```http
Authorization: Bearer <access-token>
```

Ролі: `User`, `Admin`. Swagger має Bearer security scheme; натисни **Authorize** і встав token.

## Endpoint groups

| Method | Path | Доступ | Призначення |
| --- | --- | --- | --- |
| `POST` | `/api/Auth/register` | Публічний | Реєстрація |
| `POST` | `/api/Auth/login` | Публічний | Токени доступу й оновлення |
| `POST` | `/api/Auth/refresh` | Публічний | Оновлення пари token-ів |
| `GET` | `/api/Recipes` | Публічний | Список рецептів |
| `GET` | `/api/Recipes/{id}` | Публічний | Деталі рецепта |
| `POST` | `/api/Recipes` | User/Admin | Створення рецепта |
| `PATCH` | `/api/Recipes/{id}` | Author User/Admin | Часткове оновлення |
| `DELETE` | `/api/Recipes/{id}` | Author User/Admin | Видалення |
| `POST` | `/api/Recipes/{id}/review` | User/Admin | Rating/review |
| `GET` | `/api/Category` | Публічний | Список категорій |
| `GET` | `/api/Category/{id}` | Публічний | Категорія |
| `GET` | `/api/Users` | Публічний | Список користувачів |
| `GET` | `/api/Users/{id}` | Публічний | Профіль користувача |
| `GET` | `/api/Users/{id}/recipes` | Публічний | Рецепти користувача |
| `POST` | `/api/Files/pfp` | User/Admin | Upload profile image |
| `POST` | `/api/Files/recipe/{recipeId}` | Recipe author | Upload recipe image |
| `GET` | `/api/Files/presigned-url?key=...` | Публічний | Тимчасовий S3 URL |
| `POST` | `/api/admin/AdminCategory` | Admin | Створення категорії |
| `POST` | `/api/admin/AdminRecipe` | Admin | Створення рецепта від admin |
| `PUT` | `/api/admin/AdminRecipe/{id}` | Admin | Повне admin-оновлення |
| `DELETE` | `/api/admin/AdminRecipe/{id}` | Admin | Admin-видалення |
| `POST` | `/api/admin/AdminUsers` | Admin | Створення користувача |
| `PUT` | `/api/admin/AdminUsers/{id}` | Admin | Admin-оновлення користувача |
| `DELETE` | `/api/admin/AdminUsers/{id}` | Admin | Admin-видалення користувача |

Назви admin paths походять безпосередньо з `[controller]` і наразі містять `AdminRecipe`, `AdminUsers` та `AdminCategory`.

## Типові відповіді

- `200 OK` — успішний read/update або login;
- `201 Created` — створено рецепт;
- `204 No Content` — успішний patch/delete;
- `400 Bad Request` — validation/business rule;
- `401 Unauthorized` — відсутній або невалідний token;
- `403 Forbidden` — роль або ownership не дозволяє операцію;
- `404 Not Found` — ресурс не знайдений.

## Files і S3

Кінцеві точки завантаження приймають `multipart/form-data` з полем `file`. Завантаження зображення рецепта також очікує поле форми `type`. Поточний ліміт запиту — 10 MiB. Для реального тесту потрібні чинні бакет, регіон та облікові дані S3.

## Відомі розбіжності

Фронтенд наразі викликає `POST /api/Recipes/{id}/likes`, але такої кінцевої точки в бекенді немає. Запит очікувано завершується помилкою, після чого фронтенд відкочує оптимістичну зміну. До узгодження контракту цей сценарій не слід вважати успішно інтегрованим.
