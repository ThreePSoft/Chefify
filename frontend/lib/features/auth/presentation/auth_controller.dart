import 'package:flutter/widgets.dart';
import 'package:frontend/features/auth/domain/auth_repository.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;
  AuthSession? _session;
  AuthFailureKind? _failure;
  bool _isBusy = false;
  bool _isRestored = false;
  Future<void>? _restoreFuture;

  AuthUser? get user => _session?.user;
  String? get accessToken => _session?.accessToken;
  AuthFailureKind? get failure => _failure;
  bool get isBusy => _isBusy;
  bool get isRestored => _isRestored;
  bool get isAuthenticated => _session != null;

  Future<void> restore() => _restoreFuture ??= _restore();

  Future<void> _restore() async {
    try {
      _session = await _repository.restoreSession();
    } on Object {
      _session = null;
    } finally {
      _isRestored = true;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _repository.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.register(name: name, email: email, password: password),
    );
  }

  Future<void> signOut() async {
    _failure = null;
    await _repository.signOut();
    _session = null;
    notifyListeners();
  }

  void clearFailure() {
    if (_failure == null) {
      return;
    }
    _failure = null;
    notifyListeners();
  }

  Future<bool> _run(Future<AuthSession> Function() operation) async {
    if (_isBusy) {
      return false;
    }
    _isBusy = true;
    _failure = null;
    notifyListeners();
    try {
      _session = await operation();
      return true;
    } on AuthFailure catch (error) {
      _failure = error.kind;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final controller = maybeOf(context);
    assert(controller != null, 'AuthScope is missing in widget tree.');
    return controller!;
  }

  static AuthController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
  }
}
