# Контракт frontend → backend

[English version](../en/frontend-backend-contract.md) · [Індекс документації](README.md)

Це перелік даних, під які frontend Chefify уже має інтерфейс, але поточний API віддає їх не повністю або в несумісному форматі. Документ є завданням для backend-розробника; frontend не повинен компенсувати ці прогалини вигаданими production-даними.

## Профілі та автори рецептів

### Прев’ю рецепта

`GET /api/Recipes` і `GET /api/Users/{userId}/recipes` мають повертати однакову форму картки:

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

Що треба виправити:

- додати стабільний `creatorId`; username не можна використовувати як ідентифікатор, бо він змінюється і не є унікальним;
- у `GET /api/Users/{id}/recipes` заповнювати `id`, рейтинг, категорію, теги та автора так само, як у загальному списку;
- повертати `category.id`, а не лише `categoryName`, щоб форма редагування могла вибрати правильну категорію;
- віддавати avatar reference/URL автора, thumbnail і фактичну кількість вподобань;
- `GET /api/Users/{id}` має містити щонайменше `id`, `username`, `profilePictureRef` і агреговані `recipesCount`/`favoritesCount`, якщо ці лічильники зберігає сервер.

Поки `creatorId` відсутній, frontend має сумісний fallback за username. Це лише тимчасова сумісність і не гарантує правильний профіль при однакових або змінених іменах.

## Сторінка конкретного рецепта

Frontend має завантажувати повну модель через `GET /api/Recipes/{id}`. Відповідь повинна містити:

- `id`, `title`, `description`;
- `cookingTime` у хвилинах: діапазон `1..10080` (до 7 днів). Поточне backend-обмеження `480` не відповідає формі;
- `difficulty` у діапазоні `1..5`;
- `category: { id, name }` та `tags`;
- `creator: { id, username, profilePictureRef }`;
- `imageUrl` і `thumbnailUrl` або стабільні file references, з яких API формує доступні URL;
- `rating`, `reviewsCount`, `likesCount` і `isLiked` для авторизованого користувача;
- `blocks` у збереженому порядку з типом, вмістом і налаштуваннями, які надсилає редактор.

Не слід генерувати rating, likes або reviews на сервері для production-відповіді. Порожні колекції повертаються як `[]`, відсутні необов’язкові зображення — як `null`.

## Вподобання

Frontend очікує ідемпотентну зміну стану, а не endpoint з довільним `delta`:

- `PUT /api/Recipes/{id}/like` — поставити вподобання;
- `DELETE /api/Recipes/{id}/like` — прибрати вподобання;
- обидва endpoint потребують bearer token;
- повторний `PUT` або `DELETE` не має двічі змінювати лічильник;
- відповідь: `{ "isLiked": true, "likesCount": 126 }`.

Потрібна унікальна пара `(UserId, RecipeId)` у таблиці вподобань. Локальні bookmarks frontend не є заміною серверних favorites і не повинні бути джерелом істини між пристроями.

## Відгуки

Поточний backend має створення review, але сторінці також потрібне читання:

- `GET /api/Recipes/{id}/reviews?page=1&pageSize=20`;
- відповідь містить `items`, `page`, `pageSize`, `totalCount`;
- item: `id`, `authorId`, `authorUsername`, `authorProfilePictureRef`, `rating`, `comment`, `createdAt`;
- `POST /api/Recipes/{id}/review` після створення повертає створений item, а не порожню відповідь;
- визначити політику: один review на користувача або окреме редагування/видалення; закріпити її у валідації й статусах `409/404/403`.

## Створення рецепта

Форма frontend уже оперує днями, категорією, текстовими тегами, hero image та структурованими blocks. Backend-контракт потрібно узгодити:

- підняти максимум `CookingTime` до `10080` хвилин;
- категорія має приймати ID із `GET /api/Category`; у кожному середовищі повинні існувати погоджені 5 категорій зі стабільними ID;
- визначити один формат тегів: або `tagIds` із endpoint пошуку/створення тегів, або нормалізовані `tags: string[]`. Поточна форма не може надійно перетворити текстові теги на `TagsId` без API;
- задокументувати discriminator і JSON-схему кожного block type, включно з вкладеними блоками, фото, YouTube, note, divider та їхніми style settings;
- після `POST /api/Recipes` повертати `201` з `{ "id": 42 }` і `Location`, щоб frontend одразу відкрив створений рецепт;
- upload hero/block images має бути прив’язаний до recipe ID і повертати reference/URL для подальшого збереження.

## Критерії готовності backend

- OpenAPI/Swagger показує всі поля й статуси вище.
- Обидва recipe preview endpoints мають один контракт і contract tests.
- Профіль автора визначається тільки за user ID.
- Деталі, likes, favorites і reviews переживають перезапуск та доступні з іншого браузера.
- Немає production fallback на mock/generated data.

