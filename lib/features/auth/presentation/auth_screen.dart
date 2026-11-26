import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/aura_colors.dart';
import '../../../core/widgets/aura_sigil_logo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../binder/presentation/widgets/language_menu.dart';
import '../data/repositories/auth_repository.dart';
import '../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(padding: EdgeInsets.only(right: 8), child: LanguageMenu()),
        ],
      ),
      body: AuraBackdrop(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: AuraSigilLogo(
                        size: 104,
                        semanticLabel: l10n.auraLogoDescription,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const AuraWordmark(fontSize: 32),
                    const SizedBox(height: 14),
                    Text(
                      l10n.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AuraColors.champagneLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.authSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AuraColors.silverMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _loading ? null : _handleGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 26),
                      label: Text(l10n.continueWithGoogle),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _handleApple,
                      icon: const Icon(Icons.apple, size: 22),
                      label: Text(l10n.continueWithApple),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _loading ? null : _openEmailDialog,
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: Text(l10n.signInWithEmail),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogle() async {
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleApple() async {
    setState(() => _loading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithApple();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openEmailDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _EmailSignInDialog(
        onSubmit: (email, password) async {
          await ref
              .read(authStateProvider.notifier)
              .signInWithEmail(email: email, password: password);
        },
      ),
    );
  }
}

class _EmailSignInDialog extends StatefulWidget {
  const _EmailSignInDialog({required this.onSubmit});

  final Future<void> Function(String email, String password) onSubmit;

  @override
  State<_EmailSignInDialog> createState() => _EmailSignInDialogState();
}

class _EmailSignInDialogState extends State<_EmailSignInDialog> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AuraColors.smokedCharcoal,
      title: Text(l10n.signInWithEmail),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.emailLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: l10n.passwordLabel),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AuraColors.psychicMagenta),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(l10n.signInButton),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } on AuthRepositoryException {
      if (mounted) {
        setState(() {
          _submitting = false;
          _errorMessage = l10n.emailPasswordRequired;
        });
      }
    }
  }
}
