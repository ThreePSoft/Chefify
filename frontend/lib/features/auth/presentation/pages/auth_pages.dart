import 'package:flutter/material.dart';
import 'package:frontend/app/router.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:frontend/core/constants/app_spacing.dart';
import 'package:frontend/core/localization/app_strings.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/chefify_brand_mark.dart';
import 'package:frontend/features/auth/domain/auth_session.dart';
import 'package:frontend/features/auth/presentation/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final auth = AuthScope.of(context);
    return _AuthPageShell(
      title: strings.signInTitle,
      subtitle: strings.signInSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _EmailField(controller: _emailController),
            const SizedBox(height: AppSpacing.md),
            _PasswordField(
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            if (auth.failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              _AuthError(message: _failureMessage(strings, auth.failure!)),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const ValueKey('auth-login-submit'),
              label: strings.logIn,
              isExpanded: true,
              onPressed: auth.isBusy ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            _AuthSwitch(
              prompt: strings.noAccount,
              action: strings.createAccount,
              route: AppRouter.register,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    auth.clearFailure();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted && success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.profile, (route) => false);
    }
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final auth = AuthScope.of(context);
    return _AuthPageShell(
      title: strings.registerTitle,
      subtitle: strings.registerSubtitle,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const ValueKey('auth-name-field'),
              controller: _nameController,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: InputDecoration(
                labelText: strings.nameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return strings.requiredField;
                if (name.length < 3) return strings.shortName;
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _EmailField(controller: _emailController),
            const SizedBox(height: AppSpacing.md),
            _PasswordField(
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggleVisibility: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const ValueKey('auth-confirm-password-field'),
              controller: _confirmationController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: strings.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
              ),
              validator: (value) => value == _passwordController.text
                  ? null
                  : strings.passwordsDoNotMatch,
              onFieldSubmitted: (_) => _submit(),
            ),
            if (auth.failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              _AuthError(message: _failureMessage(strings, auth.failure!)),
            ],
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              key: const ValueKey('auth-register-submit'),
              label: strings.createAccount,
              isExpanded: true,
              onPressed: auth.isBusy ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.md),
            _AuthSwitch(
              prompt: strings.alreadyHaveAccount,
              action: strings.logIn,
              route: AppRouter.login,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = AuthScope.of(context);
    auth.clearFailure();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (mounted && success) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.profile, (route) => false);
    }
  }
}

class _AuthPageShell extends StatelessWidget {
  const _AuthPageShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = AppSpacing.horizontalPaddingForWidth(
              constraints.maxWidth,
            );
            const brandClearance = 82.0;
            final centeredHeight = (constraints.maxHeight - 2 * brandClearance)
                .clamp(0.0, double.infinity)
                .toDouble();

            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      brandClearance,
                      horizontalPadding,
                      brandClearance,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: centeredHeight),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Container(
                            key: const ValueKey('auth-card'),
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: palette.cardsSurface,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              border: Border.all(color: palette.borders),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  subtitle,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: palette.secondaryText),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                child,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: horizontalPadding,
                  top: AppSpacing.sm,
                  child: _AuthBrand(homeRoute: AppRouter.home),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand({required this.homeRoute});

  final String homeRoute;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('auth-brand'),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () => Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(homeRoute, (route) => false),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ChefifyBrandMark(
                key: ValueKey('auth-brand-mark'),
                size: 46,
                borderRadius: 13,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Chefify',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return TextFormField(
      key: const ValueKey('auth-email-field'),
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: InputDecoration(
        labelText: strings.emailLabel,
        prefixIcon: const Icon(Icons.mail_outline_rounded),
      ),
      validator: (value) {
        final email = value?.trim() ?? '';
        if (email.isEmpty) return strings.requiredField;
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
          return strings.invalidEmail;
        }
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return TextFormField(
      key: const ValueKey('auth-password-field'),
      controller: controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(
        labelText: strings.passwordLabel,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return strings.requiredField;
        if (value.length < 8) return strings.shortPassword;
        return null;
      },
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  const _AuthSwitch({
    required this.prompt,
    required this.action,
    required this.route,
  });

  final String prompt;
  final String action;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(route),
          child: Text(action),
        ),
      ],
    );
  }
}

class _AuthError extends StatelessWidget {
  const _AuthError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

String _failureMessage(AppStrings strings, AuthFailureKind failure) {
  return switch (failure) {
    AuthFailureKind.invalidCredentials => strings.invalidCredentials,
    AuthFailureKind.emailAlreadyExists => strings.emailAlreadyExists,
    AuthFailureKind.network ||
    AuthFailureKind.timeout => strings.authNetworkError,
    AuthFailureKind.invalidResponse ||
    AuthFailureKind.server => strings.authServerError,
  };
}
