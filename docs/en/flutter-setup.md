# Installing Flutter SDK

[Українська версія](../uk/flutter-setup.md) · [Documentation index](README.md)

Chefify uses Flutter `3.41.9`. The single version source is `frontend/.flutter-version`. Repository setup scripts locate a compatible SDK or install one locally.

## Recommended option

A global Flutter installation is not required. Let the setup script download the SDK into `.flutter-sdk` at the repository root. Git ignores this directory, and it does not affect other Flutter projects.

## Windows PowerShell

From the repository root:

```powershell
.\tools\flutter\setup.ps1
```

When no compatible SDK is found, the script offers:

1. provide the root of an existing Flutter SDK;
2. install the pinned SDK into `.flutter-sdk`;
3. exit setup.

Option `2` is recommended for a first-time setup. The script:

1. reads `frontend/.flutter-version`;
2. downloads official Flutter release metadata;
3. resolves the archive for the pinned version;
4. downloads the archive;
5. verifies its SHA-256 against release metadata;
6. extracts the SDK into `.flutter-sdk`;
7. stores the path in `.tooling/flutter-sdk-path.txt`.

Verify the installation:

```powershell
.\tools\flutter\flutterw.ps1 --version
```

The expected version is `Flutter 3.41.9`.

If PowerShell blocks local scripts, run the wrapper through:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\flutter\flutterw.ps1 --version
```

## Windows CMD

The CMD wrapper uses the same PowerShell setup:

```bat
tools\flutter\flutterw.bat --version
```

If the SDK is not configured yet, run `tools\flutter\setup.ps1` in PowerShell first.

## Linux and macOS

Automatic installation requires `curl`, `python3`, and an extraction tool (`unzip` for zip or `tar` for tar archives).

```bash
chmod +x tools/flutter/setup.sh
./tools/flutter/setup.sh
```

Choose local installation when no compatible SDK exists. Then resolve the exact executable:

```bash
FLUTTER_BIN="$(./tools/flutter/setup.sh --print-flutter-executable | tail -n 1)"
"$FLUTTER_BIN" --version
```

Use `$FLUTTER_BIN` for project commands:

```bash
cd frontend
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" analyze --no-pub
```

## Use an existing SDK

The SDK must be version `3.41.9`. Provide its root explicitly through an environment variable.

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

The root is the directory containing `bin/flutter` or `bin/flutter.bat`, not the `bin` directory itself.

## SDK lookup order

The order is the same on supported platforms:

1. `CHEFIFY_FLUTTER_SDK`;
2. path stored in `.tooling/flutter-sdk-path.txt`;
3. repository-local `.flutter-sdk`;
4. `flutter` in `PATH`.

A candidate with a different version is ignored.

## Non-interactive setup

Automation can install the pinned SDK without a prompt:

```powershell
.\tools\flutter\setup.ps1 -InstallLocal -PrintFlutterExecutable
```

```bash
./tools/flutter/setup.sh --install-local --print-flutter-executable
```

The GitHub Actions workflow uses this mode and caches `.flutter-sdk` by the contents of `frontend/.flutter-version`.

## Upgrade Flutter

Do not run `flutter upgrade` against the project SDK. An upgrade must be a dedicated change:

1. update `frontend/.flutter-version`;
2. validate `pubspec.lock` with the new version;
3. run analyze, tests, and release build;
4. validate the Docker build;
5. update both `docs/uk` and `docs/en`.

## Reset local setup

To select the SDK again, remove only the saved path:

```powershell
Remove-Item .tooling\flutter-sdk-path.txt
.\tools\flutter\setup.ps1
```

Deleting `.flutter-sdk` forces setup to download the complete SDK again. Before doing so, confirm the path belongs to this repository.

Common issues are covered in [Troubleshooting](troubleshooting.md#flutter-wrapper-cannot-find-the-sdk).
