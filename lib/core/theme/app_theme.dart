// app_theme.dart
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// --- Custom Extensions ---

@immutable
class GradientColors extends ThemeExtension<GradientColors> {
  final LinearGradient primaryGradient;
  final LinearGradient accentGradient;

  const GradientColors({
    required this.primaryGradient,
    required this.accentGradient,
  });

  @override
  GradientColors copyWith({
    LinearGradient? primaryGradient,
    LinearGradient? accentGradient,
  }) {
    return GradientColors(
      primaryGradient: primaryGradient ?? this.primaryGradient,
      accentGradient: accentGradient ?? this.accentGradient,
    );
  }

  @override
  GradientColors lerp(ThemeExtension<GradientColors>? other, double t) {
    if (other is! GradientColors) return this;
    return GradientColors(
      primaryGradient:
          LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      accentGradient:
          LinearGradient.lerp(accentGradient, other.accentGradient, t)!,
    );
  }
}

@immutable
class CustomShadows extends ThemeExtension<CustomShadows> {
  final List<BoxShadow> cardShadows;

  const CustomShadows({required this.cardShadows});

  @override
  CustomShadows copyWith({List<BoxShadow>? cardShadows}) {
    return CustomShadows(cardShadows: cardShadows ?? this.cardShadows);
  }

  @override
  CustomShadows lerp(ThemeExtension<CustomShadows>? other, double t) {
    if (other is! CustomShadows) return this;
    return CustomShadows(
      cardShadows: List.generate(
        cardShadows.length,
        (i) => BoxShadow.lerp(cardShadows[i], other.cardShadows[i], t)!,
      ),
    );
  }
}

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color success;
  final Color warning;
  final Color info;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  @override
  StatusColors copyWith({Color? success, Color? warning, Color? info}) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// --- Core Theme Builder ---

class AppTheme {
  static const Color _primarySeedColor = Color(0xFF1565C0); // Navy
  static const Color _secondarySeedColor = Color(0xFF0277BD); // Accent Navy

  static ColorScheme _getColorScheme(Brightness brightness) {
    final primaryCore = CorePalette.of(_primarySeedColor.value);
    final secondaryCore = CorePalette.of(_secondarySeedColor.value);

    if (brightness == Brightness.light) {
      return ColorScheme(
        brightness: Brightness.light,
        primary: Color(primaryCore.primary.get(40)),
        onPrimary: Colors.white,
        primaryContainer: Color(primaryCore.primary.get(90)),
        onPrimaryContainer: Color(primaryCore.primary.get(10)),
        secondary: Color(secondaryCore.secondary.get(40)),
        onSecondary: Colors.white,
        secondaryContainer: Color(secondaryCore.secondary.get(90)),
        onSecondaryContainer: Color(secondaryCore.secondary.get(10)),
        tertiary: Color(secondaryCore.tertiary.get(40)),
        onTertiary: Colors.white,
        tertiaryContainer: Color(secondaryCore.tertiary.get(90)),
        onTertiaryContainer: Color(secondaryCore.tertiary.get(10)),
        error: const Color(0xFFB3261E),
        onError: Colors.white,
        errorContainer: const Color(0xFFF9DEDC),
        onErrorContainer: const Color(0xFF410E0B),
        surface: const Color(0xFFFAFAFA),
        onSurface: const Color(0xFF1A1A1A),
        surfaceContainerHighest: Color(primaryCore.neutralVariant.get(90)),
        onSurfaceVariant: Color(primaryCore.neutralVariant.get(30)),
        outline: Color(primaryCore.neutralVariant.get(50)),
        inverseSurface: const Color(0xFF2C2C2C),
        onInverseSurface: Colors.white,
        inversePrimary: Color(primaryCore.primary.get(80)),
        shadow: Colors.black.withOpacity(0.25),
        scrim: Colors.black.withOpacity(0.45),
      );
    } else {
      return ColorScheme(
        brightness: Brightness.dark,
        primary: Color(primaryCore.primary.get(80)),
        onPrimary: Color(primaryCore.primary.get(20)),
        primaryContainer: Color(primaryCore.primary.get(30)),
        onPrimaryContainer: Color(primaryCore.primary.get(90)),
        secondary: Color(secondaryCore.secondary.get(80)),
        onSecondary: Color(secondaryCore.secondary.get(20)),
        secondaryContainer: Color(secondaryCore.secondary.get(30)),
        onSecondaryContainer: Color(secondaryCore.secondary.get(90)),
        tertiary: Color(secondaryCore.tertiary.get(80)),
        onTertiary: Color(secondaryCore.tertiary.get(20)),
        tertiaryContainer: Color(secondaryCore.tertiary.get(30)),
        onTertiaryContainer: Color(secondaryCore.tertiary.get(90)),
        error: const Color(0xFFF2B8B5),
        onError: const Color(0xFF601410),
        errorContainer: const Color(0xFF8C1D18),
        onErrorContainer: const Color(0xFFFFDAD6),
        surface: const Color(0xFF121212),
        onSurface: const Color(0xFFE0E0E0),
        surfaceContainerHighest: Color(primaryCore.neutralVariant.get(30)),
        onSurfaceVariant: Color(primaryCore.neutralVariant.get(80)),
        outline: Color(primaryCore.neutralVariant.get(60)),
        inverseSurface: const Color(0xFFEAEAEA),
        onInverseSurface: const Color(0xFF1A1A1A),
        inversePrimary: Color(primaryCore.primary.get(40)),
        shadow: Colors.black,
        scrim: Colors.black,
      );
    }
  }

  static ThemeData lightTheme() =>
      _baseTheme(_getColorScheme(Brightness.light));
  static ThemeData darkTheme() => _baseTheme(_getColorScheme(Brightness.dark));

  static ThemeData _baseTheme(ColorScheme scheme) {
    const radius = 12.0;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      /// ✅ Attach extensions here
      extensions: [
        GradientColors(
          primaryGradient: LinearGradient(
            colors: [scheme.primary, scheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          accentGradient: LinearGradient(
            colors: [scheme.secondary, scheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        CustomShadows(
          cardShadows: [
            BoxShadow(
              color: scheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        StatusColors(
          success: Colors.green.shade600,
          warning: Colors.orange.shade700,
          info: Colors.blue.shade600,
        ),
      ],
    );
  }
}
