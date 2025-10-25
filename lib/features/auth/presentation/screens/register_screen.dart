import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_constants.dart';
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

  static const _brandBlue = Color(0xFF1C34C5);
  static const _accentBlue = Color(0xFF3B4FF9);
  static const _borderColor = Color(0xFFE0E0E0);
  static const _iconColor = Color(0xFF6B7280);

  double _w(BuildContext context) => MediaQuery.of(context).size.width;
  double _h(BuildContext context) => MediaQuery.of(context).size.height;
  double _clamp(double value, double min, double max) =>
      value < min ? min : (value > max ? max : value);

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

  InputDecoration _buildInputDecoration(
    BuildContext context,
    String hintText, {
    Widget? suffixIcon,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIcon:
          prefixIcon == null ? null : Icon(prefixIcon, color: _iconColor),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _brandBlue, width: 1.4),
      ),
      suffixIcon: suffixIcon,
    );
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
    final colorScheme = Theme.of(context).colorScheme;

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

    final maxFormWidth = _clamp(_w(context) * 0.92, 320, 420);
    final headerHeight = _clamp(_h(context) * 0.2, 140, 180);
    const horizontalInset = 16.0;
    const headerHorizontalInset = 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _brandBlue,
              _accentBlue,
              Colors.white,
            ],
            stops: [0.0, 0.38, 0.68],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxFormWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Enter your credentials to create an account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
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
                              controller: _firstNameController,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'First Name',
                                prefixIcon: Icons.person_outline,
                              ),
                              validator: (value) =>
                                  AuthValidators.name(value, 'First name'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'Last Name',
                                prefixIcon: Icons.person_outline,
                              ),
                              validator: (value) =>
                                  AuthValidators.name(value, 'Last name'),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'Email Address',
                                prefixIcon: Icons.email_outlined,
                              ),
                              validator: AuthValidators.email,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              textInputAction: TextInputAction.next,
                              obscureText: _obscurePassword,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'Password',
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() =>
                                        _obscurePassword = !_obscurePassword);
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _iconColor,
                                  ),
                                ),
                              ),
                              validator: AuthValidators.password,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              textInputAction: TextInputAction.next,
                              obscureText: _obscureConfirmPassword,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'Confirm Password',
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() => _obscureConfirmPassword =
                                        !_obscureConfirmPassword);
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _iconColor,
                                  ),
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth = constraints.maxWidth;
                                return DropdownButtonFormField<String>(
                                  value: _selectedGrade,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _brandBlue,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Grade',
                                    prefixIcon: Icons.school_outlined,
                                  ),
                                  validator: AuthValidators.grade,
                                  items: AppConfig.supportedGrades
                                      .map(
                                        (grade) => DropdownMenuItem(
                                          value: grade,
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: SizedBox(
                                            width: itemWidth,
                                            child: Text(
                                              AppConfig.getGradeDisplayName(
                                                grade,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (value) => setState(
                                          () => _selectedGrade = value),
                                  dropdownColor: Colors.white,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth = constraints.maxWidth;
                                return DropdownButtonFormField<String>(
                                  value: _selectedSyllabus,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _brandBlue,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Syllabus',
                                    prefixIcon: Icons.menu_book_outlined,
                                  ),
                                  validator: AuthValidators.syllabus,
                                  items: AppConfig.supportedSyllabi
                                      .map(
                                        (syllabus) => DropdownMenuItem(
                                          value: syllabus,
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: SizedBox(
                                            width: itemWidth,
                                            child: Text(
                                              AppConfig.getSyllabusDisplayName(
                                                syllabus,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (value) => setState(
                                            () => _selectedSyllabus = value,
                                          ),
                                  dropdownColor: Colors.white,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final itemWidth = constraints.maxWidth;
                                return DropdownButtonFormField<String>(
                                  value: _selectedProvince,
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: _brandBlue,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    'Province',
                                    prefixIcon: Icons.location_on_outlined,
                                  ),
                                  validator: AuthValidators.province,
                                  items: AppConfig.southAfricanProvinces
                                      .map(
                                        (province) => DropdownMenuItem(
                                          value: province,
                                          alignment:
                                              AlignmentDirectional.centerStart,
                                          child: SizedBox(
                                            width: itemWidth,
                                            child: Text(
                                              AppConfig.getProvinceDisplayName(
                                                province,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: authState.isLoading
                                      ? null
                                      : (value) => setState(
                                            () => _selectedProvince = value,
                                          ),
                                  dropdownColor: Colors.white,
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _schoolNameController,
                              textInputAction: TextInputAction.done,
                              enabled: !authState.isLoading,
                              decoration: _buildInputDecoration(
                                context,
                                'School Name (Optional)',
                                prefixIcon: Icons.apartment_outlined,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 40,
                              child: FilledButton(
                                onPressed: authState.isLoading
                                    ? null
                                    : _handleRegister,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _brandBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: authState.isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                          children: const [
                            TextSpan(
                              text: 'By clicking continue, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                          TextButton(
                            onPressed: authState.isLoading
                                ? null
                                : () => context.go(AppConstants.loginRoute),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: _brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
