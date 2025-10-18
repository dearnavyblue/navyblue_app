import 'package:flutter/material.dart';
import '../data/pick_greeting.dart';
import 'greeting_patterns_corner.dart';

class GreetingBar extends StatelessWidget {
  final String displayName;
  final CornerPattern pattern; // none / cornerDots / cornerChevrons
  final double patternOpacity; // 0.0–0.12 is subtle
  final Color? brandTint;
  final double height; // parent controls height
  final double colorCoverage; // 0.0..0.30 (tinted slab % of height)

  const GreetingBar({
    super.key,
    required this.displayName,
    this.pattern = CornerPattern.cornerDots,
    this.patternOpacity = 0.06,
    this.brandTint,
    this.height = 184,
    this.colorCoverage = 0.88, // < 30%
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final msg = pickGreeting(displayName);

    final leftColor = theme.colorScheme.onSecondary; // base stays light
    final baseRight = colorForEmoji(msg.emoji, theme.colorScheme);
    final rightColor =
        _mix(baseRight, brandTint ?? baseRight, brandTint == null ? 0 : 0.25);
    final textColor = _bestOn(leftColor);

    return LayoutBuilder(
      builder: (context, constraints) {
        final slabHeight = height * colorCoverage.clamp(0.0, 0.30);

        return SizedBox(
          height: height,
          child: Stack(
            children: [
              // 1) Base: light surface across entire card
              Positioned.fill(child: ColoredBox(color: leftColor)),

              // 2) TOP slab: color -> white (fade) top→bottom, confined to <30% height
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: slabHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                        colors: [
                        rightColor, // strong at top-right
                        Color.lerp(rightColor, leftColor, 0.55)!, // soften
                        leftColor.withOpacity(0.0), // hard stop to transparent
                        leftColor.withOpacity(0.0), // keep rest fully clear
                      ],
                      stops: const [0.0, 0.18, 0.30, 1.0],
                      transform: const GradientRotation(-0.785398)
                    ),
                  ),
                ),
              ),

              // 3) Subtle corner pattern (still anchored at top-right)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CornerPatternPainter(
                      style: pattern,
                      color: Colors.black.withOpacity(patternOpacity),
                    ),
                  ),
                ),
              ),

              // 4) Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // prevents overflow
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.l1,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            msg.l2 ?? 'Welcome back',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacity(0.75),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _EmojiPill(
                        emoji: msg.emoji,
                        bg: rightColor,
                        fg: _bestOn(rightColor)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _mix(Color a, Color b, double t) {
    int ch(int x, int y) => (x + ((y - x) * t)).round();
    return Color.fromARGB(
        255, ch(a.red, b.red), ch(a.green, b.green), ch(a.blue, b.blue));
  }

  Color _bestOn(Color c) =>
      c.computeLuminance() > 0.55 ? Colors.black : Colors.white;
}

class _EmojiPill extends StatelessWidget {
  final String emoji;
  final Color bg;
  final Color fg;
  const _EmojiPill({required this.emoji, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Greeting icon $emoji',
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: bg.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Text(emoji, style: TextStyle(fontSize: 18, color: fg)),
      ),
    );
  }
}

/// same mapping as before
Color colorForEmoji(String emoji, ColorScheme scheme) {
  switch (emoji) {
    case '⚡':
      return const Color(0xFFFFD54F);
    case '🔥':
      return const Color(0xFFFF8A65);
    case '👑':
      return const Color(0xFFF6C945);
    case '🌿':
      return const Color(0xFF81C784);
    case '📖':
      return const Color(0xFF64B5F6);
    case '🎯':
      return const Color(0xFFE57373);
    case '📰':
      return const Color(0xFFB0BEC5);
    case '😂':
      return const Color(0xFFFFF176);
    case '🥊':
      return const Color(0xFF90CAF9);
    case '🙂':
      return const Color(0xFFA5B4FC);
    case '😏':
      return const Color(0xFF9FE3D3);
    case '😎':
      return const Color(0xFFA7F3D0);
    default:
      return scheme.tertiaryContainer;
  }
}
