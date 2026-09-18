# Встановлення Flutter SDK

[English version](../en/flutter-setup.md) · [До змісту](README.md)

Chefify використовує Flutter `3.41.9`. Єдиним джерелом версії є `frontend/.flutter-version`. Репозиторій містить інсталяційні скрипти, які знаходять сумісний SDK або встановлюють його локально.

## Рекомендований варіант

Не потрібно встановлювати Flutter глобально. Дозволь інсталяційному скрипту завантажити SDK у `.flutter-sdk` в корені репозиторію. Ця папка ігнорується Git і не впливає на інші Flutter-проєкти.

## Windows PowerShell

Із кореня репозиторію:

```powershell
.\tools\flutter\setup.ps1
```

Якщо сумісний SDK не знайдено, скрипт запропонує:

1. вказати кореневий каталог уже встановленого Flutter SDK;
2. встановити зафіксовану версію SDK у `.flutter-sdk`;
3. завершити налаштування.

Для першого налаштування рекомендований варіант `2`. Скрипт:

1. читає версію з `frontend/.flutter-version`;
2. завантажує офіційні Flutter release metadata;
3. знаходить архів потрібної версії;
4. завантажує архів;
5. перевіряє SHA-256 із release metadata;
6. розпаковує SDK у `.flutter-sdk`;
7. зберігає шлях у `.tooling/flutter-sdk-path.txt`.

Перевір встановлення:

```powershell
.\tools\flutter\flutterw.ps1 --version
```

Очікувана версія — `Flutter 3.41.9`.

Якщо PowerShell блокує локальні скрипти, можна запустити обгортку так:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\flutter\flutterw.ps1 --version
```

## Windows CMD

CMD-обгортка використовує те саме налаштування PowerShell:

```bat
tools\flutter\flutterw.bat --version
```

Якщо SDK ще не налаштований, спочатку виконай `tools\flutter\setup.ps1` у PowerShell.

## Linux і macOS

Для автоматичного встановлення потрібні `curl`, `python3` і інструмент розпакування (`unzip` для zip або `tar` для tar-архіву).

```bash
chmod +x tools/flutter/setup.sh
./tools/flutter/setup.sh
```

Обери локальне встановлення, якщо сумісного SDK немає. Потім отримай шлях до виконуваного файла:

```bash
FLUTTER_BIN="$(./tools/flutter/setup.sh --print-flutter-executable | tail -n 1)"
"$FLUTTER_BIN" --version
```

Використовуй `$FLUTTER_BIN` для команд проєкту:

```bash
cd frontend
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" analyze --no-pub
```

## Використання вже встановленого SDK

SDK має бути саме версії `3.41.9`. Його кореневий каталог можна явно передати через змінну середовища.

PowerShell:

```powershell
$env:CHEFIFY_FLUTTER_SDK='D:\Tools\flutter'
.\tools\flutter\setup.ps1
```

Bash:

```bash
export CHEFIFY_FLUTTER_SDK="/opt/flutter"
./tools/flutter/setup.sh
```

Кореневий каталог — це папка, що містить `bin/flutter` або `bin/flutter.bat`, а не сама папка `bin`.

## Порядок пошуку SDK

Порядок однаковий на підтримуваних платформах:

1. `CHEFIFY_FLUTTER_SDK`;
2. шлях із `.tooling/flutter-sdk-path.txt`;
3. `.flutter-sdk` у репозиторії;
4. `flutter` у `PATH`.

Кандидат з іншою версією не використовується.

## Неінтерактивне налаштування

Автоматизація може встановити зафіксовану версію SDK без запиту:

```powershell
.\tools\flutter\setup.ps1 -InstallLocal -PrintFlutterExecutable
```

```bash
./tools/flutter/setup.sh --install-local --print-flutter-executable
```

GitHub Actions використовує цей режим і кешує `.flutter-sdk` за вмістом `frontend/.flutter-version`.

## Оновлення Flutter

Не запускай `flutter upgrade` для проєктного SDK. Оновлення має бути окремою зміною:

1. змінити `frontend/.flutter-version`;
2. перевірити `pubspec.lock` на новій версії;
3. виконати статичний аналіз, тести й збірку для випуску;
4. перевірити Docker-збірку;
5. оновити документацію в `docs/uk` та `docs/en`.

## Скидання локального налаштування

Щоб повторно вибрати SDK, видали лише збережений шлях:

```powershell
Remove-Item .tooling\flutter-sdk-path.txt
.\tools\flutter\setup.ps1
```

Видалення `.flutter-sdk` змусить інсталяційний скрипт повторно завантажити весь SDK. Перед цим переконайся, що шлях справді належить цьому репозиторію.

Типові проблеми описані у [вирішенні проблем](troubleshooting.md#flutter-обгортка-не-знаходить-sdk).
