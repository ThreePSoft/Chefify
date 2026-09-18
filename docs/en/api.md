# API

[Українська версія](../uk/api.md) · [Documentation index](README.md)

## Base addresses

- Docker API: `http://localhost:8080`
- Local `dotnet run --launch-profile http`: `http://localhost:5294`
- Swagger in Development: `/swagger`
- API prefix: `/api`

Swagger is the source of truth for request and response schemas. This page documents navigation and access rules rather than duplicating every DTO.

## Authorization

Protected endpoints expect:

```http
Authorization: Bearer <access-token>
```

Roles are `User` and `Admin`. Swagger contains a Bearer security scheme; click **Authorize** and provide the token.

## Endpoint groups

| Method | Path | Access | Purpose |
| --- | --- | --- | --- |
| `POST` | `/api/Auth/register` | Public | Register |
| `POST` | `/api/Auth/login` | Public | Access and refresh tokens |
| `POST` | `/api/Auth/refresh` | Public | Refresh token pair |
| `GET` | `/api/Recipes` | Public | Recipe list |
| `GET` | `/api/Recipes/{id}` | Public | Recipe details |
| `POST` | `/api/Recipes` | User/Admin | Create recipe |
| `PATCH` | `/api/Recipes/{id}` | Author User/Admin | Partial update |
| `DELETE` | `/api/Recipes/{id}` | Author User/Admin | Delete recipe |
| `POST` | `/api/Recipes/{id}/review` | User/Admin | Rating/review |
| `GET` | `/api/Category` | Public | Category list |
| `GET` | `/api/Category/{id}` | Public | Category details |
| `GET` | `/api/Users` | Public | User list |
| `GET` | `/api/Users/{id}` | Public | User profile |
| `GET` | `/api/Users/{id}/recipes` | Public | User recipes |
| `POST` | `/api/Files/pfp` | User/Admin | Upload profile image |
| `POST` | `/api/Files/recipe/{recipeId}` | Recipe author | Upload recipe image |
| `GET` | `/api/Files/presigned-url?key=...` | Public | Temporary S3 URL |
| `POST` | `/api/admin/AdminCategory` | Admin | Create category |
| `POST` | `/api/admin/AdminRecipe` | Admin | Create recipe as admin |
| `PUT` | `/api/admin/AdminRecipe/{id}` | Admin | Full admin update |
| `DELETE` | `/api/admin/AdminRecipe/{id}` | Admin | Admin delete |
| `POST` | `/api/admin/AdminUsers` | Admin | Create user |
| `PUT` | `/api/admin/AdminUsers/{id}` | Admin | Admin user update |
| `DELETE` | `/api/admin/AdminUsers/{id}` | Admin | Admin user delete |

Admin path names come directly from `[controller]` and currently contain `AdminRecipe`, `AdminUsers`, and `AdminCategory`.

## Common responses

- `200 OK` — successful read, update, or login;
- `201 Created` — recipe created;
- `204 No Content` — successful patch or delete;
- `400 Bad Request` — validation or business rule failure;
- `401 Unauthorized` — missing or invalid token;
- `403 Forbidden` — role or ownership denies the operation;
- `404 Not Found` — resource does not exist.

## Files and S3

Upload endpoints accept `multipart/form-data` with a `file` field. Recipe upload also expects the `type` form field. The current request size limit is 10 MiB. Real testing requires a valid S3 bucket, region, and credentials.

## Known mismatch

The frontend currently calls `POST /api/Recipes/{id}/likes`, but the backend has no such endpoint. The expected behavior is a failed request followed by an optimistic-like rollback in the UI. This flow is not fully integrated until the contract is aligned.
