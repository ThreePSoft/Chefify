import 'package:flutter/widgets.dart';
import 'package:frontend/app/app_settings.dart';

class AppStrings {
  const AppStrings._(this.language);

  final AppLanguage language;

  static AppStrings of(BuildContext context) {
    return AppStrings._(AppSettingsScope.of(context).language);
  }

  String _value({required String en, required String uk, required String es}) {
    return switch (language) {
      AppLanguage.en => en,
      AppLanguage.uk => uk,
      AppLanguage.es => es,
    };
  }

  String get recipes => _value(en: 'Recipes', uk: 'Рецепти', es: 'Recetas');
  String get mealPlans =>
      _value(en: 'Meal plans', uk: 'Плани харчування', es: 'Planes');
  String get pricing => _value(en: 'Pricing', uk: 'Ціни', es: 'Precios');
  String get community =>
      _value(en: 'Community', uk: 'Спільнота', es: 'Comunidad');
  String get blog => _value(en: 'Blog', uk: 'Блог', es: 'Blog');
  String get support => _value(en: 'Support', uk: 'Підтримка', es: 'Soporte');
  String get logIn => _value(en: 'Log in', uk: 'Увійти', es: 'Ingresar');
  String get getStarted =>
      _value(en: 'Get started', uk: 'Почати', es: 'Comenzar');
  String get profile => _value(en: 'Profile', uk: 'Профіль', es: 'Perfil');
  String get signOut =>
      _value(en: 'Sign out', uk: 'Вийти', es: 'Cerrar sesión');
  String get signInTitle => _value(
    en: 'Welcome back',
    uk: 'Раді бачити знову',
    es: 'Te damos la bienvenida',
  );
  String get signInSubtitle => _value(
    en: 'Sign in to save recipes and manage your Chefify profile.',
    uk: 'Увійдіть, щоб зберігати рецепти та керувати профілем Chefify.',
    es: 'Inicia sesión para guardar recetas y gestionar tu perfil.',
  );
  String get registerTitle => _value(
    en: 'Create your account',
    uk: 'Створіть свій акаунт',
    es: 'Crea tu cuenta',
  );
  String get registerSubtitle => _value(
    en: 'Join Chefify and keep everything you cook in one place.',
    uk: 'Приєднуйтесь до Chefify і зберігайте все, що готуєте, в одному місці.',
    es: 'Únete a Chefify y guarda todo lo que cocinas en un solo lugar.',
  );
  String get nameLabel => _value(en: 'Display name', uk: 'Ім’я', es: 'Nombre');
  String get emailLabel =>
      _value(en: 'Email', uk: 'Електронна пошта', es: 'Correo');
  String get passwordLabel =>
      _value(en: 'Password', uk: 'Пароль', es: 'Contraseña');
  String get confirmPasswordLabel => _value(
    en: 'Confirm password',
    uk: 'Підтвердьте пароль',
    es: 'Confirma la contraseña',
  );
  String get createAccount =>
      _value(en: 'Create account', uk: 'Створити акаунт', es: 'Crear cuenta');
  String get noAccount => _value(
    en: 'New to Chefify?',
    uk: 'Ще немає акаунта?',
    es: '¿Nuevo en Chefify?',
  );
  String get alreadyHaveAccount => _value(
    en: 'Already have an account?',
    uk: 'Уже маєте акаунт?',
    es: '¿Ya tienes una cuenta?',
  );
  String get requiredField => _value(
    en: 'This field is required.',
    uk: 'Це поле обов’язкове.',
    es: 'Este campo es obligatorio.',
  );
  String get invalidEmail => _value(
    en: 'Enter a valid email address.',
    uk: 'Введіть коректну електронну адресу.',
    es: 'Introduce un correo válido.',
  );
  String get shortName => _value(
    en: 'Use at least 3 characters.',
    uk: 'Використайте щонайменше 3 символи.',
    es: 'Usa al menos 3 caracteres.',
  );
  String get shortPassword => _value(
    en: 'Use at least 8 characters.',
    uk: 'Використайте щонайменше 8 символів.',
    es: 'Usa al menos 8 caracteres.',
  );
  String get passwordsDoNotMatch => _value(
    en: 'Passwords do not match.',
    uk: 'Паролі не збігаються.',
    es: 'Las contraseñas no coinciden.',
  );
  String get invalidCredentials => _value(
    en: 'The email or password is incorrect.',
    uk: 'Неправильна електронна адреса або пароль.',
    es: 'El correo o la contraseña son incorrectos.',
  );
  String get emailAlreadyExists => _value(
    en: 'An account with this email already exists.',
    uk: 'Акаунт із цією електронною адресою вже існує.',
    es: 'Ya existe una cuenta con este correo.',
  );
  String get authNetworkError => _value(
    en: 'Could not reach the Chefify API. Make sure the backend is running and try again.',
    uk: 'Не вдалося підключитися до API Chefify. Переконайтеся, що backend запущений, і спробуйте ще раз.',
    es: 'No se pudo conectar con la API de Chefify. Comprueba que el backend esté activo.',
  );
  String get authServerError => _value(
    en: 'Authentication is temporarily unavailable. Please try again.',
    uk: 'Авторизація тимчасово недоступна. Спробуйте ще раз.',
    es: 'La autenticación no está disponible. Inténtalo de nuevo.',
  );
  String get accountDetails => _value(
    en: 'Account details',
    uk: 'Дані акаунта',
    es: 'Datos de la cuenta',
  );
  String get memberRole => _value(en: 'Role', uk: 'Роль', es: 'Rol');
  String get profileGuestTitle => _value(
    en: 'Sign in to open your profile',
    uk: 'Увійдіть, щоб відкрити профіль',
    es: 'Inicia sesión para abrir tu perfil',
  );

  String get myRecipes =>
      _value(en: 'My recipes', uk: 'Мої рецепти', es: 'Mis recetas');
  String get favoriteRecipes => _value(
    en: 'Favorite recipes',
    uk: 'Улюблені рецепти',
    es: 'Recetas favoritas',
  );
  String get settings =>
      _value(en: 'Settings', uk: 'Налаштування', es: 'Configuración');
  String get createRecipe =>
      _value(en: 'Create recipe', uk: 'Створити рецепт', es: 'Crear receta');
  String get editProfile =>
      _value(en: 'Edit profile', uk: 'Редагувати профіль', es: 'Editar perfil');
  String get saveChanges =>
      _value(en: 'Save changes', uk: 'Зберегти зміни', es: 'Guardar cambios');
  String get noOwnRecipes => _value(
    en: 'You have not published any recipes yet.',
    uk: 'Ви ще не опублікували жодного рецепта.',
    es: 'Aún no has publicado ninguna receta.',
  );
  String get noFavoriteRecipes => _value(
    en: 'Recipes you save will appear here.',
    uk: 'Збережені рецепти з’являться тут.',
    es: 'Las recetas que guardes aparecerán aquí.',
  );
  String get appearance =>
      _value(en: 'Appearance', uk: 'Вигляд', es: 'Apariencia');
  String get profileDarkTheme =>
      _value(en: 'Dark theme', uk: 'Темна тема', es: 'Tema oscuro');
  String get profileLanguage =>
      _value(en: 'Language', uk: 'Мова', es: 'Idioma');

  String get categories =>
      _value(en: 'Categories', uk: 'Категорії', es: 'Categorías');
  String get categoriesEyebrow =>
      _value(en: 'CATEGORIES', uk: 'КАТЕГОРІЇ', es: 'CATEGORÍAS');
  String get exploreEveryCategory => _value(
    en: 'Explore every category',
    uk: 'Перегляньте всі категорії',
    es: 'Explora todas las categorías',
  );
  String get categoriesSubtitle => _value(
    en: 'From quick dinners to baking projects, every Chefify lane is here.',
    uk: 'Від швидких вечерь до випічки — у Chefify є все.',
    es: 'Desde cenas rápidas hasta repostería: todo está en Chefify.',
  );
  String categoryCount(int count) => _value(
    en: '$count categories',
    uk: '$count категорій',
    es: '$count categorías',
  );
  String get searchCategories => _value(
    en: 'Search categories',
    uk: 'Пошук категорій',
    es: 'Buscar categorías',
  );
  String get clearCategorySearch => _value(
    en: 'Clear category search',
    uk: 'Очистити пошук категорій',
    es: 'Limpiar búsqueda de categorías',
  );
  String get savedOnly =>
      _value(en: 'Saved only', uk: 'Лише збережені', es: 'Solo guardadas');
  String get noCategoriesFound => _value(
    en: 'No categories found',
    uk: 'Категорій не знайдено',
    es: 'No se encontraron categorías',
  );
  String get recipesEyebrow =>
      _value(en: 'RECIPES', uk: 'РЕЦЕПТИ', es: 'RECETAS');
  String get findYourNextCook => _value(
    en: 'Find your next cook',
    uk: 'Знайдіть наступний рецепт',
    es: 'Encuentra tu próxima receta',
  );
  String get recipesSubtitle => _value(
    en: 'Browse every Chefify recipe and narrow the list by taste, time, saved items, or rating.',
    uk: 'Переглядайте рецепти Chefify та фільтруйте їх за смаком, часом, збереженнями чи рейтингом.',
    es: 'Explora las recetas y filtra por sabor, tiempo, guardados o valoración.',
  );
  String recipeCount(int count) =>
      _value(en: '$count recipes', uk: '$count рецептів', es: '$count recetas');
  String get noRecipesMatch => _value(
    en: 'No recipes match these filters',
    uk: 'Жоден рецепт не відповідає фільтрам',
    es: 'Ninguna receta coincide con los filtros',
  );
  String get tryDifferentRecipeFilters => _value(
    en: 'Try a different search term, category, or cook time.',
    uk: 'Спробуйте інший запит, категорію або час приготування.',
    es: 'Prueba otro término, categoría o tiempo de cocción.',
  );
  String get sortBy =>
      _value(en: 'Sort by', uk: 'Сортувати', es: 'Ordenar por');
  String get featured =>
      _value(en: 'Featured', uk: 'Рекомендовані', es: 'Destacadas');
  String get highestRated => _value(
    en: 'Highest rated',
    uk: 'Найвищий рейтинг',
    es: 'Mejor valoradas',
  );
  String get quickest =>
      _value(en: 'Quickest', uk: 'Найшвидші', es: 'Más rápidas');
  String get clear => _value(en: 'Clear', uk: 'Очистити', es: 'Limpiar');
  String get cookTime =>
      _value(en: 'Cook time', uk: 'Час приготування', es: 'Tiempo');
  String get any => _value(en: 'Any', uk: 'Будь-який', es: 'Cualquiera');
  String get upTo20Minutes =>
      _value(en: '20 min or less', uk: 'До 20 хв', es: '20 min o menos');
  String get upTo30Minutes =>
      _value(en: '30 min or less', uk: 'До 30 хв', es: '30 min o menos');
  String get over30Minutes =>
      _value(en: 'Over 30 min', uk: 'Понад 30 хв', es: 'Más de 30 min');
  String get searchRecipes =>
      _value(en: 'Search recipes', uk: 'Пошук рецептів', es: 'Buscar recetas');
  String get clearSearch =>
      _value(en: 'Clear search', uk: 'Очистити пошук', es: 'Limpiar búsqueda');
  String get removeFilter =>
      _value(en: 'Remove filter', uk: 'Прибрати фільтр', es: 'Quitar filtro');
  String get couldNotLoadRecipes => _value(
    en: 'Could not load recipes',
    uk: 'Не вдалося завантажити рецепти',
    es: 'No se pudieron cargar las recetas',
  );
  String get tryAgain =>
      _value(en: 'Try again', uk: 'Спробувати ще раз', es: 'Reintentar');
  String get unexpectedError => _value(
    en: 'An unexpected error occurred. Please try again.',
    uk: 'Сталася неочікувана помилка. Спробуйте ще раз.',
    es: 'Ocurrió un error inesperado. Inténtalo de nuevo.',
  );
  String get connectionError => _value(
    en: 'Check your connection and try again.',
    uk: 'Перевірте з’єднання та спробуйте ще раз.',
    es: 'Comprueba tu conexión e inténtalo de nuevo.',
  );
  String get requestTimeout => _value(
    en: 'The server took too long to respond. Please retry.',
    uk: 'Сервер надто довго не відповідає. Спробуйте ще раз.',
    es: 'El servidor tardó demasiado. Inténtalo de nuevo.',
  );
  String get recipesUnavailable => _value(
    en: 'The recipes service is temporarily unavailable.',
    uk: 'Сервіс рецептів тимчасово недоступний.',
    es: 'El servicio de recetas no está disponible.',
  );
  String get invalidRecipesResponse => _value(
    en: 'The server returned data Chefify could not read.',
    uk: 'Сервер повернув дані, які Chefify не вдалося прочитати.',
    es: 'El servidor devolvió datos que Chefify no pudo leer.',
  );
  String get category =>
      _value(en: 'Category', uk: 'Категорія', es: 'Categoría');
  String get searchCategory => _value(
    en: 'Search category',
    uk: 'Пошук категорії',
    es: 'Buscar categoría',
  );
  String get difficulty =>
      _value(en: 'Difficulty', uk: 'Складність', es: 'Dificultad');
  String get setCookingTime => _value(
    en: 'Set cooking time',
    uk: 'Вкажіть час приготування',
    es: 'Indica el tiempo de cocción',
  );
  String get days => _value(en: 'Days', uk: 'Дні', es: 'Días');
  String get hours => _value(en: 'Hours', uk: 'Години', es: 'Horas');
  String get minutes => _value(en: 'Minutes', uk: 'Хвилини', es: 'Minutos');
  String get cancel => _value(en: 'Cancel', uk: 'Скасувати', es: 'Cancelar');
  String get apply => _value(en: 'Apply', uk: 'Застосувати', es: 'Aplicar');
  String decrease(String label) => _value(
    en: 'Decrease $label',
    uk: 'Зменшити: $label',
    es: 'Disminuir: $label',
  );
  String increase(String label) => _value(
    en: 'Increase $label',
    uk: 'Збільшити: $label',
    es: 'Aumentar: $label',
  );
  String get recipeTitle => _value(en: 'Title', uk: 'Назва', es: 'Título');
  String get recipeDescription =>
      _value(en: 'Description', uk: 'Опис', es: 'Descripción');
  String get whyChefify =>
      _value(en: 'WHY CHEFIFY', uk: 'ЧОМУ CHEFIFY', es: 'POR QUÉ CHEFIFY');
  String get benefitsTitle => _value(
    en: 'Everything you need in one kitchen flow',
    uk: 'Усе необхідне в одному кулінарному процесі',
    es: 'Todo lo que necesitas en un solo flujo',
  );
  String get benefitsSubtitle => _value(
    en: 'From planning to plating, Chefify removes friction at every step.',
    uk: 'Від планування до подачі — Chefify спрощує кожен крок.',
    es: 'Desde planificar hasta servir, Chefify simplifica cada paso.',
  );
  String get discover =>
      _value(en: 'DISCOVER', uk: 'ВІДКРИВАЙТЕ', es: 'DESCUBRE');
  String get browseByCategory => _value(
    en: 'Browse by category',
    uk: 'Перегляд за категоріями',
    es: 'Explorar por categoría',
  );
  String get categorySectionSubtitle => _value(
    en: 'Pick a mood and we will find recipes that fit your day.',
    uk: 'Оберіть настрій — ми знайдемо рецепти для вашого дня.',
    es: 'Elige un estilo y encontraremos recetas para tu día.',
  );
  String get seeAll =>
      _value(en: 'See all', uk: 'Переглянути всі', es: 'Ver todo');
  String get featuredRecipe => _value(
    en: 'FEATURED RECIPE',
    uk: 'РЕКОМЕНДОВАНИЙ РЕЦЕПТ',
    es: 'RECETA DESTACADA',
  );
  String get featuredRecipeDescription => _value(
    en: 'A bright and savory dinner packed with herbs, citrus, and texture. Perfect for guests or a premium weeknight meal.',
    uk: 'Яскрава й насичена вечеря з травами, цитрусом і цікавою текстурою. Ідеально для гостей або особливого буднього вечора.',
    es: 'Una cena sabrosa con hierbas, cítricos y textura. Ideal para invitados o una noche especial.',
  );
  String get openFullRecipe => _value(
    en: 'Open full recipe',
    uk: 'Відкрити повний рецепт',
    es: 'Abrir receta completa',
  );
  String get takeChefifyWithYou => _value(
    en: 'Take Chefify wherever you cook',
    uk: 'Беріть Chefify всюди, де готуєте',
    es: 'Lleva Chefify donde cocines',
  );
  String get mobileAppSubtitle => _value(
    en: 'Sync shopping lists, watch guided steps, and track your progress from phone to desktop.',
    uk: 'Синхронізуйте списки покупок, дивіться покрокові інструкції та відстежуйте прогрес на телефоні й комп’ютері.',
    es: 'Sincroniza compras, sigue los pasos y controla tu progreso en todos tus dispositivos.',
  );
  String get downloadAppStore => _value(
    en: 'Download on App Store',
    uk: 'Завантажити в App Store',
    es: 'Descargar en App Store',
  );
  String get downloadGooglePlay => _value(
    en: 'Get it on Google Play',
    uk: 'Завантажити з Google Play',
    es: 'Disponible en Google Play',
  );
  String get newsletterTitle => _value(
    en: 'Weekly recipes in your inbox',
    uk: 'Щотижневі рецепти у вашій пошті',
    es: 'Recetas semanales en tu correo',
  );
  String get newsletterSubtitle => _value(
    en: 'No spam. Just fresh ideas and practical kitchen tips every Thursday.',
    uk: 'Без спаму. Лише свіжі ідеї та практичні поради щочетверга.',
    es: 'Sin spam. Solo ideas frescas y consejos prácticos cada jueves.',
  );
  String get enterEmail => _value(
    en: 'Enter your email',
    uk: 'Введіть електронну адресу',
    es: 'Introduce tu correo',
  );
  String get subscribe =>
      _value(en: 'Subscribe', uk: 'Підписатися', es: 'Suscribirse');
  String get socialProof =>
      _value(en: 'SOCIAL PROOF', uk: 'ВІДГУКИ СПІЛЬНОТИ', es: 'TESTIMONIOS');
  String get testimonialsTitle => _value(
    en: 'Loved by cooks around the world',
    uk: 'Улюблений сервіс кулінарів у всьому світі',
    es: 'Amado por cocineros de todo el mundo',
  );
  String get testimonialsSubtitle => _value(
    en: 'Real stories from people who upgraded their daily kitchen routine.',
    uk: 'Реальні історії людей, які покращили свою щоденну кухонну рутину.',
    es: 'Historias reales de personas que mejoraron su rutina en la cocina.',
  );
  String get trendingNow =>
      _value(en: 'TRENDING NOW', uk: 'ЗАРАЗ У ТРЕНДІ', es: 'TENDENCIAS');
  String get trendingRecipesTitle => _value(
    en: 'Recipes everyone is saving',
    uk: 'Рецепти, які зберігають усі',
    es: 'Recetas que todos guardan',
  );
  String get trendingRecipesSubtitle => _value(
    en: 'Hand-picked weekly from the most cooked dishes in the Chefify community.',
    uk: 'Щотижнева добірка найпопулярніших страв спільноти Chefify.',
    es: 'Selección semanal de los platos más cocinados por la comunidad.',
  );
  String get overview => _value(en: 'OVERVIEW', uk: 'ОГЛЯД', es: 'RESUMEN');
  String get cookProfile => _value(
    en: 'Cook profile',
    uk: 'Профіль приготування',
    es: 'Perfil de preparación',
  );
  String get time => _value(en: 'Time', uk: 'Час', es: 'Tiempo');
  String recipeTimeDescription(int value) => _value(
    en: '$value minutes from prep to plate.',
    uk: '$value хвилин від підготовки до подачі.',
    es: '$value minutos desde la preparación hasta servir.',
  );
  String get rating => _value(en: 'Rating', uk: 'Рейтинг', es: 'Valoración');
  String recipeRatingDescription(String value) => _value(
    en: '$value average community rating.',
    uk: '$value — середня оцінка спільноти.',
    es: '$value de valoración media de la comunidad.',
  );
  String get notes => _value(en: 'NOTES', uk: 'НОТАТКИ', es: 'NOTAS');
  String get whatToExpect =>
      _value(en: 'What to expect', uk: 'Чого очікувати', es: 'Qué esperar');
  String get saveForLater => _value(
    en: 'Save for later',
    uk: 'Зберегти на потім',
    es: 'Guardar para después',
  );
  String get bookmarkHint => _value(
    en: 'Use the bookmark button to keep this recipe in your saved list.',
    uk: 'Натисніть кнопку закладки, щоб додати рецепт до збережених.',
    es: 'Usa el marcador para guardar esta receta en tu lista.',
  );
  String get defaultRecipeDescription => _value(
    en: 'A practical Chefify recipe built for repeat cooking, balanced flavor, and a clean weeknight workflow.',
    uk: 'Практичний рецепт Chefify зі збалансованим смаком для зручного щоденного приготування.',
    es: 'Una receta práctica de Chefify, equilibrada y pensada para repetir.',
  );
  String get expert => _value(en: 'Expert', uk: 'Експертно', es: 'Experto');
  String get easyDifficultyDescription => _value(
    en: 'Quick and low-friction for busy days.',
    uk: 'Швидко й просто для завантажених днів.',
    es: 'Rápido y sencillo para días ocupados.',
  );
  String get mediumDifficultyDescription => _value(
    en: 'Comfortable weeknight cooking with a few focused steps.',
    uk: 'Зручне буденне приготування з кількома важливими кроками.',
    es: 'Cocina cómoda entre semana con unos pasos clave.',
  );
  String get hardDifficultyDescription => _value(
    en: 'Best when you have a little more room for prep and finishing.',
    uk: 'Підійде, коли є трохи більше часу на підготовку та завершення.',
    es: 'Ideal cuando tienes más tiempo para preparar y terminar.',
  );
  String get expertDifficultyDescription => _value(
    en: 'A more involved cook for confident, detail-focused sessions.',
    uk: 'Складніший рецепт для впевненого й уважного приготування.',
    es: 'Una preparación más exigente y centrada en los detalles.',
  );
  String get reviews => _value(en: 'REVIEWS', uk: 'ВІДГУКИ', es: 'RESEÑAS');
  String get communityRating => _value(
    en: 'Community rating',
    uk: 'Оцінка спільноти',
    es: 'Valoración de la comunidad',
  );
  String reviewsCount(int count) => _value(
    en: '$count cooks reviewed this recipe.',
    uk: '$count користувачів оцінили цей рецепт.',
    es: '$count cocineros valoraron esta receta.',
  );
  String reviewRange(int start, int end, int total) => _value(
    en: 'Showing $start-$end of $total',
    uk: 'Показано $start–$end із $total',
    es: 'Mostrando $start-$end de $total',
  );
  String get previousReviewPage => _value(
    en: 'Previous review page',
    uk: 'Попередня сторінка відгуків',
    es: 'Página anterior de reseñas',
  );
  String get nextReviewPage => _value(
    en: 'Next review page',
    uk: 'Наступна сторінка відгуків',
    es: 'Página siguiente de reseñas',
  );
  String get leaveReview => _value(
    en: 'Leave your review',
    uk: 'Залиште свій відгук',
    es: 'Deja tu reseña',
  );
  String get reviewHint => _value(
    en: 'Share what worked, what changed, or who loved it.',
    uk: 'Розкажіть, що вдалося, що ви змінили та кому сподобалося.',
    es: 'Comparte qué funcionó, qué cambiaste o a quién le gustó.',
  );
  String get postReview => _value(
    en: 'Post review',
    uk: 'Опублікувати відгук',
    es: 'Publicar reseña',
  );
  String starRating(int value) => _value(
    en: '$value star rating',
    uk: 'Оцінка: $value зірок',
    es: 'Valoración de $value estrellas',
  );
  String get recipeNotFound => _value(
    en: 'Recipe not found',
    uk: 'Рецепт не знайдено',
    es: 'Receta no encontrada',
  );
  String get recipeUnavailable => _value(
    en: 'This recipe is not available in the current catalog.',
    uk: 'Цей рецепт недоступний у поточному каталозі.',
    es: 'Esta receta no está disponible en el catálogo actual.',
  );
  String get author => _value(en: 'AUTHOR', uk: 'АВТОР', es: 'AUTOR');
  String recipesByAuthor(int count) => _value(
    en: '$count recipes by this author',
    uk: '$count рецептів цього автора',
    es: '$count recetas de este autor',
  );
  String noAuthorRecipes(String name) => _value(
    en: 'No recipes from $name yet',
    uk: 'У $name поки немає рецептів',
    es: '$name todavía no tiene recetas',
  );
  String get likeRecipe => _value(
    en: 'Like recipe',
    uk: 'Вподобати рецепт',
    es: 'Me gusta la receta',
  );
  String get removeRecipeLike => _value(
    en: 'Remove recipe like',
    uk: 'Прибрати вподобання',
    es: 'Quitar Me gusta',
  );
  String get editRecipe =>
      _value(en: 'Edit recipe', uk: 'Редагувати рецепт', es: 'Editar receta');
  String get updateLikeFailed => _value(
    en: 'Could not update the recipe like. Please retry.',
    uk: 'Не вдалося оновити вподобання. Спробуйте ще раз.',
    es: 'No se pudo actualizar el Me gusta. Inténtalo de nuevo.',
  );
  String get tag => _value(en: 'Tag', uk: 'Тег', es: 'Etiqueta');
  String get cancelTag => _value(
    en: 'Cancel tag',
    uk: 'Скасувати додавання тегу',
    es: 'Cancelar etiqueta',
  );
  String get templates =>
      _value(en: 'Templates', uk: 'Шаблони', es: 'Plantillas');
  String get blocks => _value(en: 'Blocks', uk: 'Блоки', es: 'Bloques');
  String get expandBlockPalette => _value(
    en: 'Expand block palette',
    uk: 'Розгорнути панель блоків',
    es: 'Expandir panel de bloques',
  );
  String get collapseBlockPalette => _value(
    en: 'Collapse block palette',
    uk: 'Згорнути панель блоків',
    es: 'Contraer panel de bloques',
  );
  String get openBlockSettings => _value(
    en: 'Open block settings',
    uk: 'Відкрити налаштування блока',
    es: 'Abrir ajustes del bloque',
  );
  String get collapseBlockSettings => _value(
    en: 'Collapse block settings',
    uk: 'Згорнути налаштування блока',
    es: 'Contraer ajustes del bloque',
  );
  String get deleteBlock =>
      _value(en: 'Delete block', uk: 'Видалити блок', es: 'Eliminar bloque');
  String get writeHeading => _value(
    en: 'Write a heading',
    uk: 'Напишіть заголовок',
    es: 'Escribe un título',
  );
  String get writeParagraph => _value(
    en: 'Write a paragraph',
    uk: 'Напишіть абзац',
    es: 'Escribe un párrafo',
  );
  String get writeQuote => _value(
    en: 'Write a quote',
    uk: 'Напишіть цитату',
    es: 'Escribe una cita',
  );
  String get noteStyle =>
      _value(en: 'Note style', uk: 'Стиль нотатки', es: 'Estilo de nota');
  String get textSize =>
      _value(en: 'Text size', uk: 'Розмір тексту', es: 'Tamaño de texto');
  String get lineStyle =>
      _value(en: 'Line style', uk: 'Стиль лінії', es: 'Estilo de línea');
  String get thickness => _value(en: 'Thickness', uk: 'Товщина', es: 'Grosor');
  String get videoSize =>
      _value(en: 'Video size', uk: 'Розмір відео', es: 'Tamaño del video');
  String get imageMode =>
      _value(en: 'Image mode', uk: 'Режим зображень', es: 'Modo de imagen');
  String get mediaSize =>
      _value(en: 'Media size', uk: 'Розмір медіа', es: 'Tamaño multimedia');
  String get autoplayPace => _value(
    en: 'Autoplay pace',
    uk: 'Швидкість автопрокрутки',
    es: 'Ritmo de reproducción',
  );
  String replacePhoto(int index) => _value(
    en: 'Replace photo $index',
    uk: 'Замінити фото $index',
    es: 'Reemplazar foto $index',
  );
  String deletePhoto(int index) => _value(
    en: 'Delete photo $index',
    uk: 'Видалити фото $index',
    es: 'Eliminar foto $index',
  );
  String get width => _value(en: 'Width', uk: 'Ширина', es: 'Ancho');
  String get alignment =>
      _value(en: 'Alignment', uk: 'Вирівнювання', es: 'Alineación');
  String get spacing => _value(en: 'Spacing', uk: 'Відступи', es: 'Espaciado');
  String get variant => _value(en: 'Variant', uk: 'Варіант', es: 'Variante');
  String get block => _value(en: 'Block', uk: 'Блок', es: 'Bloque');
  String get content => _value(en: 'Content', uk: 'Вміст', es: 'Contenido');
  String get youtubeVideo =>
      _value(en: 'YouTube video', uk: 'Відео YouTube', es: 'Video de YouTube');
  String get youtubeUrl =>
      _value(en: 'YouTube URL', uk: 'Посилання YouTube', es: 'URL de YouTube');

  String get trustedBy => _value(
    en: 'Trusted by 120K+ home cooks',
    uk: 'Нам довіряють 120K+ кухарів',
    es: 'Más de 120K cocineros confían',
  );

  String get heroTitle => _value(
    en: 'Cook with confidence.\nServe with style.',
    uk: 'Готуй впевнено.\nПодавай стильно.',
    es: 'Cocina con confianza.\nSirve con estilo.',
  );

  String get heroSubtitle => _value(
    en: 'Chefify helps you discover recipes, manage meal plans, and cook faster without sacrificing flavor.',
    uk: 'Chefify допомагає відкривати нові рецепти, планувати харчування та готувати швидше без компромісів у смаку.',
    es: 'Chefify te ayuda a descubrir recetas, planificar comidas y cocinar más rápido sin perder sabor.',
  );

  String get startFreeTrial => _value(
    en: 'Start free trial',
    uk: 'Почати безкоштовно',
    es: 'Probar gratis',
  );

  String get browseRecipes => _value(
    en: 'Browse recipes',
    uk: 'Переглянути рецепти',
    es: 'Ver recetas',
  );

  String get recipeOfTheDay =>
      _value(en: 'Recipe of the day', uk: 'Рецепт дня', es: 'Receta del día');

  String get photoPlaceholder => _value(
    en: 'Photo placeholder',
    uk: 'Місце для фото',
    es: 'Espacio para foto',
  );

  String get minutesShort => _value(en: 'min', uk: 'хв', es: 'min');
  String get easy => _value(en: 'Easy', uk: 'Легко', es: 'Fácil');
  String get medium => _value(en: 'Medium', uk: 'Середньо', es: 'Medio');
  String get hard => _value(en: 'Hard', uk: 'Складно', es: 'Difícil');

  String get followUs =>
      _value(en: 'Follow us', uk: 'Ми в соцмережах', es: 'Síguenos');

  String get languageLabel =>
      _value(en: 'Interface language', uk: 'Мова інтерфейсу', es: 'Idioma');

  String get themeLabel => _value(en: 'Theme', uk: 'Тема', es: 'Tema');
  String get lightTheme => _value(en: 'Light', uk: 'Світла', es: 'Claro');
  String get darkTheme => _value(en: 'Dark', uk: 'Темна', es: 'Oscuro');

  String copyright(int year) {
    return _value(
      en: '(c) $year Chefify. All rights reserved.',
      uk: '(c) $year Chefify. Усі права захищені.',
      es: '(c) $year Chefify. Todos los derechos reservados.',
    );
  }
}
