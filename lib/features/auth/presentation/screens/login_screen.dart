import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:navyblue_app/features/auth/presentation/controllers/auth_controller.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/validators/auth_validators.dart';
import '../providers/auth_presentation_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _fnEmail = FocusNode();
  final _fnPass = FocusNode();

  bool _obscure = true;
  bool _autoValidate = false;

  // —— quotes (rotate every 6s; supports long lines like in Figma)
  final List<(String, String)> _quotes = const [
    ("‘Be yourself;\neveryone else is already taken’", "Oscar Wilde"),
    ("Start before you're ready.", "Steven Pressfield"),
    ("Action cures anxiety.", "Seth Godin"),
    ("Little by little, the bird builds its nest.", "Tanzanian Proverb"),
  ];
  int _q = 0;
  Timer? _ticker;

  // tokens
  static const _brandBlue = Color(0xFF1C34C5);
  static const _quoteInk = _brandBlue;

  Widget _buildGradientQuote(String text, double fontSize) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Color(0xFFCED6FF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _q = (_q + 1) % _quotes.length);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _email.dispose();
    _password.dispose();
    _fnEmail.dispose();
    _fnPass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).login(
          _email.text.trim(),
          _password.text,
        );
  }

  void _forgot() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text('Forgot password feature coming soon!'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  // —— responsiveness
  double _w(BuildContext c) => MediaQuery.of(c).size.width;
  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  InputDecoration _fieldDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandBlue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;

    // route + error listeners
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!mounted) return;

      if (next.isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(next.isAdmin ? '/admin' : AppConstants.homeRoute);
        });
      }

      if (next.error != null && next.error != prev?.error) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: scheme.error,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: scheme.onError,
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).clearError(),
              ),
            ),
          );
        });
      }
    });

    final (quote, author) = _quotes[_q];

    // Button text: Figma shows "Continue". Set here; swap to "Sign In" if needed.
    const buttonText = 'Continue';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _brandBlue,
              Color(0xFF3B4FF9),
              Colors.white,
            ],
            stops: [0.0, 0.38, 0.68],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxFormWidth = _clamp(_w(context) * 0.92, 320, 420);
              final headerHeight =
                  _clamp(constraints.maxHeight * 0.42, 260, 360);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxFormWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: headerHeight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/whole_logo.png',
                                      height: 28,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Navy Blue',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: Column(
                                    key: ValueKey(_q),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildGradientQuote(
                                        quote,
                                        _clamp(
                                          _w(context) * 0.12,
                                          30,
                                          46,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '— $author',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: _quoteInk,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Form(
                          key: _formKey,
                          autovalidateMode: _autoValidate
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _email,
                                focusNode: _fnEmail,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                enabled: !auth.isLoading,
                                decoration: _fieldDecoration(
                                  context: context,
                                  hint: 'Email Address',
                                  icon: LucideIcons.mail,
                                ),
                                validator: AuthValidators.email,
                                onFieldSubmitted: (_) => _fnPass.requestFocus(),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _password,
                                focusNode: _fnPass,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                enabled: !auth.isLoading,
                                decoration: _fieldDecoration(
                                  context: context,
                                  hint: 'Password',
                                  icon: LucideIcons.lock,
                                  suffix: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? LucideIcons.eye
                                          : LucideIcons.eyeOff,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Password is required'
                                    : null,
                                onFieldSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: auth.isLoading ? null : _forgot,
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: _brandBlue),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: FilledButton(
                                  onPressed: auth.isLoading ? null : _login,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _brandBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    buttonText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: auth.isLoading
                                  ? null
                                  : () => context.go(
                                        AppConstants.registerRoute,
                                      ),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(color: _brandBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
