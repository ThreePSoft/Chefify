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
    en: 'Chefify could not reach the server. Check your connection and try again.',
    uk: 'Chefify не вдалося з’єднатися із сервером. Перевірте мережу та спробуйте ще раз.',
    es: 'Chefify no pudo conectar con el servidor. Comprueba tu conexión.',
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
