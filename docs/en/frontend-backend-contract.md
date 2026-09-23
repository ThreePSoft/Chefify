# Frontend → backend contract

[Українська версія](../uk/frontend-backend-contract.md) · [Documentation index](README.md)

This lists data for which the Chefify frontend already has UI, while the current API returns it incompletely or in an incompatible shape. It is an implementation checklist for the backend developer; the frontend must not hide these gaps with invented production data.

## Profiles and recipe authors

`GET /api/Recipes` and `GET /api/Users/{userId}/recipes` must return the same recipe-card shape:

```json
{
  "id": 42,
  "title": "Citrus chicken",
  "description": "...",
  "cookingTime": 55,
  "difficulty": 2,
  "rating": 4.8,
  "category": { "id": 3, "name": "Dinner" },
  "tags": ["high-protein", "weeknight"],
  "creatorId": 7,
  "creatorUsername": "Chef Aria",
  "creatorProfilePictureRef": null,
  "thumbnailUrl": null,
  "likesCount": 125
}
```

Required fixes:

- add stable `creatorId`; username is mutable and is not a safe identity key;
- populate ID, rating, category, tags, and author in `GET /api/Users/{id}/recipes` exactly as in the general list;
- return `category.id`, not only `categoryName`;
- return the author avatar reference/URL, thumbnail, and real like count;
- make `GET /api/Users/{id}` include at least `id`, `username`, `profilePictureRef`, and server-owned `recipesCount`/`favoritesCount` aggregates when applicable.

Until `creatorId` exists, the frontend retains a username fallback for compatibility. It cannot guarantee correct routing after a rename or for duplicate names.

## Recipe details

The frontend should load the complete model from `GET /api/Recipes/{id}`. The response must include:

- `id`, `title`, and `description`;
- `cookingTime` in minutes, range `1..10080` (up to seven days); the current backend limit of `480` conflicts with the form;
- `difficulty` in range `1..5`;
- `category: { id, name }` and `tags`;
- `creator: { id, username, profilePictureRef }`;
- `imageUrl` and `thumbnailUrl`, or stable file references from which the API produces accessible URLs;
- `rating`, `reviewsCount`, `likesCount`, and authenticated-user `isLiked`;
- ordered `blocks` with the type, content, and editor settings that were submitted.

Production responses must not invent ratings, likes, or reviews. Empty collections are `[]`; absent optional images are `null`.

## Likes and favorites

The frontend needs idempotent state changes rather than an arbitrary counter delta:

- `PUT /api/Recipes/{id}/like` adds a like;
- `DELETE /api/Recipes/{id}/like` removes it;
- both require a bearer token;
- repeated PUT or DELETE calls must not change the count twice;
- response: `{ "isLiked": true, "likesCount": 126 }`.

Enforce a unique `(UserId, RecipeId)` pair in storage. Frontend-local bookmarks are not a cross-device source of truth for server favorites.

## Reviews

The backend currently accepts a review, but the page also needs reads:

- `GET /api/Recipes/{id}/reviews?page=1&pageSize=20`;
- response contains `items`, `page`, `pageSize`, and `totalCount`;
- item fields: `id`, `authorId`, `authorUsername`, `authorProfilePictureRef`, `rating`, `comment`, `createdAt`;
- `POST /api/Recipes/{id}/review` returns the created item rather than an empty response;
- define whether a user can create one review or can edit/delete reviews, and enforce it with documented `409/404/403` responses.

## Recipe creation

The frontend form already uses days, a category, textual tags, a hero image, and structured blocks. Align the backend contract as follows:

- raise the `CookingTime` maximum to `10080` minutes;
- accept category IDs returned by `GET /api/Category`; every environment must contain the agreed five categories with stable IDs;
- choose one tag contract: either `tagIds` plus tag search/create endpoints, or normalized `tags: string[]`; the form cannot reliably turn text into `TagsId` without an API;
- document the discriminator and JSON schema for every block type, including nested blocks, photos, YouTube, notes, dividers, and style settings;
- return `201`, `{ "id": 42 }`, and `Location` from `POST /api/Recipes` so the frontend can open the new recipe;
- bind hero/block uploads to a recipe ID and return a reference/URL that can be persisted.

## Backend definition of done

- OpenAPI/Swagger documents every field and response above.
- Both recipe-preview endpoints share one contract and contract tests.
- Author profiles are resolved only by user ID.
- Details, likes, favorites, and reviews persist across restarts and browsers.
- Production has no mock/generated-data fallback.

