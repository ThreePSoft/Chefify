# Chefify frontend

Flutter web client for Chefify. The project uses the pinned version from `.flutter-version`; use the repository wrappers instead of an arbitrary global Flutter SDK.

- [Українська документація](../docs/uk/README.md)
- [English documentation](../docs/en/README.md)
- [Frontend development — Українська](../docs/uk/development.md#flutter-sdk)
- [Frontend development — English](../docs/en/development.md#flutter-sdk)
- [Testing — Українська](../docs/uk/testing.md)
- [Testing — English](../docs/en/testing.md)

From the repository root on Windows:

```powershell
Push-Location frontend
..\tools\flutter\flutterw.ps1 pub get
..\tools\flutter\flutterw.ps1 run -d chrome --web-port 8089 --dart-define=CHEFIFY_API_BASE_URL=http://localhost:8080/api
Pop-Location
```
