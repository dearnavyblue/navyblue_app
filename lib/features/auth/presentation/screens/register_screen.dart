import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/validators/auth_validators.dart';
import '../controllers/auth_controller.dart';
import '../providers/auth_presentation_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _schoolNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _autoValidate = false;

  String? _selectedGrade;
  String? _selectedProvince;
  String? _selectedSyllabus;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _schoolNameController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() => _autoValidate = true);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          grade: _selectedGrade!,
          province: _selectedProvince!,
          syllabus: _selectedSyllabus!,
          schoolName: _schoolNameController.text.trim().isEmpty
              ? null
              : _schoolNameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!mounted) return;
      if (next.isLoggedIn) context.go(AppConstants.homeRoute);
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: colorScheme.onError,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 400;
              final horizontalPadding = isMobile ? 16.0 : 24.0;
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Name & Description
                      Text(
                        AppConfig.appName,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Create your NavyBlue account',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Form Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 16 : 24),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autoValidate
                                ? AutovalidateMode.onUserInteraction
                                : AutovalidateMode.disabled,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Names
                                isMobile
                                    ? Column(
                                        children: [
                                          TextFormField(
                                            controller: _firstNameController,
                                            textInputAction:
                                                TextInputAction.next,
                                            enabled: !authState.isLoading,
                                            decoration: InputDecoration(
                                              labelText: 'First Name',
                                              prefixIcon: Icon(
                                                  Icons.person_outlined,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 12),
                                            ),
                                            validator: (value) =>
                                                AuthValidators.name(
                                                    value, 'First name'),
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _lastNameController,
                                            textInputAction:
                                                TextInputAction.next,
                                            enabled: !authState.isLoading,
                                            decoration: InputDecoration(
                                              labelText: 'Last Name',
                                              prefixIcon: Icon(
                                                  Icons.person_outlined,
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.6)),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                      horizontal: 12),
                                            ),
                                            validator: (value) =>
                                                AuthValidators.name(
                                                    value, 'Last name'),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: _firstNameController,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                              decoration: InputDecoration(
                                                labelText: 'First Name',
                                                prefixIcon: Icon(
                                                    Icons.person_outlined,
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.6)),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 12),
                                              ),
                                              validator: (value) =>
                                                  AuthValidators.name(
                                                      value, 'First name'),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _lastNameController,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !authState.isLoading,
                                              decoration: InputDecoration(
                                                labelText: 'Last Name',
                                                prefixIcon: Icon(
                                                    Icons.person_outlined,
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.6)),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 12),
                                              ),
                                              validator: (value) =>
                                                  AuthValidators.name(
                                                      value, 'Last name'),
                                            ),
                                          ),
                                        ],
                                      ),
                                const SizedBox(height: 16),

                                // Email
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  enabled: !authState.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                  ),
                                  validator: AuthValidators.email,
                                ),
                                const SizedBox(height: 16),

                                // Password
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.next,
                                  enabled: !authState.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                  ),
                                  validator: AuthValidators.password,
                                ),
                                const SizedBox(height: 16),

                                // Confirm Password
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  textInputAction: TextInputAction.next,
                                  enabled: !authState.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    prefixIcon: Icon(Icons.lock_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    suffixIcon: IconButton(
                                      onPressed: () => setState(() =>
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword),
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                  ),
                                  validator: _validateConfirmPassword,
                                ),
                                const SizedBox(height: 16),

                                // Academic Dropdowns
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedGrade,
                                  decoration: InputDecoration(
                                    labelText: 'Grade',
                                    prefixIcon: Icon(Icons.school_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                  ),
                                  validator: AuthValidators.grade,
                                  items: AppConfig.supportedGrades
                                      .map((g) => DropdownMenuItem(
                                          value: g,
                                          child: Text(
                                              AppConfig.getGradeDisplayName(
                                                  g))))
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (v) =>
                                          setState(() => _selectedGrade = v),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedSyllabus,
                                  decoration: InputDecoration(
                                    labelText: 'Syllabus',
                                    prefixIcon: Icon(Icons.menu_book_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                  ),
                                  validator: AuthValidators.syllabus,
                                  items: AppConfig.supportedSyllabi
                                      .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(
                                              AppConfig.getSyllabusDisplayName(
                                                  s))))
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (v) =>
                                          setState(() => _selectedSyllabus = v),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedProvince,
                                  decoration: InputDecoration(
                                    labelText: 'Province',
                                    prefixIcon: Icon(Icons.location_on_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                  ),
                                  validator: AuthValidators.province,
                                  items: AppConfig.southAfricanProvinces
                                      .map((p) => DropdownMenuItem(
                                          value: p,
                                          child: Text(
                                              AppConfig.getProvinceDisplayName(
                                                  p))))
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (v) =>
                                          setState(() => _selectedProvince = v),
                                ),
                                const SizedBox(height: 16),

                                // School Name
                                TextFormField(
                                  controller: _schoolNameController,
                                  decoration: InputDecoration(
                                    labelText: 'School Name (Optional)',
                                    prefixIcon: Icon(Icons.business_outlined,
                                        color: colorScheme.onSurface
                                            .withOpacity(0.6)),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 12),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Register Button
                                FilledButton(
                                  onPressed: authState.isLoading
                                      ? null
                                      : _handleRegister,
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          ),
                                        )
                                      : const Text('Create Account'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => context.go(AppConstants.loginRoute),
                            child: Text(
                              'Sign In',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
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
