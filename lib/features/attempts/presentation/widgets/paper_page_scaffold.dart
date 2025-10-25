import 'package:flutter/material.dart';

/// A white "sheet" with A4-like look, margins and a subtle shadow.
/// Wraps your existing page content. Includes optional pinch-to-zoom (no pan)
/// so it feels like a PDF page while keeping vertical scroll intact.
class PaperPageScaffold extends StatelessWidget {
  const PaperPageScaffold({
    super.key,
    required this.child,
    this.enableZoom = true,
    this.maxScale = 2.5,
    this.horizontalMargin = 8,
    this.sheetRadius = 4,
    this.usePaperFont = true,
  });

  final Widget child;
  final bool enableZoom;
  final double maxScale;
  final double horizontalMargin;
  final double sheetRadius;
  final bool usePaperFont;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    // Keep the page comfortably centered and readable on phones & tablets.
    final sheetMaxWidth =
        media.size.width.clamp(0, 720.0) - (horizontalMargin * 2);

    final Widget inner = usePaperFont
        ? Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.apply(heightFactor: 1.15),
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(height: 1.35),
              child: child,
            ),
          )
        : child;

    final sheet = Container(
      constraints: BoxConstraints(maxWidth: sheetMaxWidth),
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 8),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
      decoration: BoxDecoration(
        color: Colors.white, // paper
        borderRadius: BorderRadius.circular(sheetRadius),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
            color: Color(0x1A000000), // subtle shadow
          ),
        ],
      ),
      child: inner,
    );

    if (!enableZoom) return Center(child: sheet);

    // Zoom without pan to avoid gesture conflict with vertical scroll.
    return Center(
      child: InteractiveViewer(
        minScale: 1,
        maxScale: maxScale,
        panEnabled: false,
        clipBehavior: Clip.none,
        child: sheet,
      ),
    );
  }
}
