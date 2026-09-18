# API

[English version](../en/api.md) · [До змісту](README.md)

## Базові адреси

- Docker API: `http://localhost:8080`
- Локальний `dotnet run --launch-profile http`: `http://localhost:5294`
- Swagger у Development: `/swagger`
- API prefix: `/api`

Swagger є джерелом актуальних request/response schemas. Цей файл описує навігацію і правила доступу, а не дублює всі DTO.

## Авторизація

Захищені endpoint-и очікують header:

```http
Authorization: Bearer <access-token>
```

Ролі: `User`, `Admin`. Swagger має Bearer security scheme; натисни **Authorize** і встав token.

## Endpoint groups

| Method | Path | Доступ | Призначення |
| --- | --- | --- | --- |
| `POST` | `/api/Auth/register` | Public | Реєстрація |
| `POST` | `/api/Auth/login` | Public | Access/refresh tokens |
| `POST` | `/api/Auth/refresh` | Public | Оновлення token pair |
| `GET` | `/api/Recipes` | Public | Список рецептів |
| `GET` | `/api/Recipes/{id}` | Public | Деталі рецепта |
| `POST` | `/api/Recipes` | User/Admin | Створення рецепта |
| `PATCH` | `/api/Recipes/{id}` | Author User/Admin | Часткове оновлення |
| `DELETE` | `/api/Recipes/{id}` | Author User/Admin | Видалення |
| `POST` | `/api/Recipes/{id}/review` | User/Admin | Rating/review |
| `GET` | `/api/Category` | Public | Список категорій |
| `GET` | `/api/Category/{id}` | Public | Категорія |
| `GET` | `/api/Users` | Public | Список користувачів |
| `GET` | `/api/Users/{id}` | Public | Профіль користувача |
| `GET` | `/api/Users/{id}/recipes` | Public | Рецепти користувача |
| `POST` | `/api/Files/pfp` | User/Admin | Upload profile image |
| `POST` | `/api/Files/recipe/{recipeId}` | Recipe author | Upload recipe image |
| `GET` | `/api/Files/presigned-url?key=...` | Public | Тимчасовий S3 URL |
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

Upload endpoint-и приймають `multipart/form-data` з полем `file`. Recipe upload також очікує form field `type`. Поточний request size limit — 10 MiB. Для реального тесту потрібні валідні S3 bucket, region і credentials.

## Відомі розбіжності

Frontend currently викликає `POST /api/Recipes/{id}/likes`, але такого endpoint-а в backend немає. Це очікувано завершується помилкою, після чого frontend відкочує optimistic like. До узгодження контракту цей flow не слід вважати успішно інтегрованим.
