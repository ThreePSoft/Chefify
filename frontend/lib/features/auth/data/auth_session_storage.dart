import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _accessTokenKey = 'chefify.auth.accessToken';
const _refreshTokenKey = 'chefify.auth.refreshToken';
const _userIdKey = 'chefify.auth.user.id';
const _userNameKey = 'chefify.auth.user.name';
const _userEmailKey = 'chefify.auth.user.email';
const _userRoleKey = 'chefify.auth.user.role';

abstract interface class AuthSessionStorage {
  Future<AuthSession?> read();

  Future<void> write(AuthSession session);

  Future<void> clear();
}

final class SharedPreferencesAuthSessionStorage implements AuthSessionStorage {
  SharedPreferencesAuthSessionStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences;

  final SharedPreferencesAsync? _preferences;
  SharedPreferencesAsync get _store => _preferences ?? SharedPreferencesAsync();

  @override
  Future<AuthSession?> read() async {
    final values = await Future.wait<String?>([
      _store.getString(_accessTokenKey),
      _store.getString(_refreshTokenKey),
      _store.getString(_userIdKey),
      _store.getString(_userNameKey),
      _store.getString(_userEmailKey),
      _store.getString(_userRoleKey),
    ]);
    if (values.any((value) => value == null || value.isEmpty)) {
      return null;
    }
    return AuthSession(
      accessToken: values[0]!,
      refreshToken: values[1]!,
      user: AuthUser(
        id: values[2]!,
        name: values[3]!,
        email: values[4]!,
        role: values[5]!,
      ),
    );
  }

  @override
  Future<void> write(AuthSession session) async {
    await Future.wait<void>([
      _store.setString(_accessTokenKey, session.accessToken),
      _store.setString(_refreshTokenKey, session.refreshToken),
      _store.setString(_userIdKey, session.user.id),
      _store.setString(_userNameKey, session.user.name),
      _store.setString(_userEmailKey, session.user.email),
      _store.setString(_userRoleKey, session.user.role),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait<void>([
      _store.remove(_accessTokenKey),
      _store.remove(_refreshTokenKey),
      _store.remove(_userIdKey),
      _store.remove(_userNameKey),
      _store.remove(_userEmailKey),
      _store.remove(_userRoleKey),
    ]);
  }
}

final class MemoryAuthSessionStorage implements AuthSessionStorage {
  MemoryAuthSessionStorage([this.session]);

  AuthSession? session;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> write(AuthSession session) async {
    this.session = session;
  }

  @override
  Future<void> clear() async {
    session = null;
  }
}
