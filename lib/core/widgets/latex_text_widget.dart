import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';

class LaTeXTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const LaTeXTextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_hasLatex(text)) {
      return Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final defaultTextStyle =
        style ?? theme.textTheme.bodyMedium ?? const TextStyle();
    final textColor = defaultTextStyle.color ??
        theme.textTheme.bodyMedium?.color ??
        Colors.black;

    return TeXWidget(
      math: text,
      textWidgetBuilder: (context, textContent) {
        return TextSpan(
          text: textContent,
          style: defaultTextStyle,
        );
      },
      inlineFormulaWidgetBuilder: (context, inlineFormula) {
        return GestureDetector(
          onTap: () => _showZoomedMath(context, inlineFormula, textColor,
              defaultTextStyle.fontSize ?? 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.transparent,
            ),
            child: TeX2SVG(
              math: inlineFormula,
              formulaWidgetBuilder: (context, svg) {
                return SvgPicture.string(
                  svg,
                  colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                  height: (defaultTextStyle.fontSize ?? 14) * 1.2,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
        );
      },
      displayFormulaWidgetBuilder: (context, displayFormula) {
        return GestureDetector(
          onTap: () => _showZoomedMath(context, displayFormula, textColor,
              (defaultTextStyle.fontSize ?? 14) * 1.5),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: Center(
              child: TeX2SVG(
                math: displayFormula,
                formulaWidgetBuilder: (context, svg) {
                  return SvgPicture.string(
                    svg,
                    colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
                    height: (defaultTextStyle.fontSize ?? 14) * 2,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showZoomedMath(BuildContext context, String formula, Color textColor,
      double baseFontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ZoomedMathDialog(
            formula: formula,
            textColor: textColor,
            baseFontSize: baseFontSize,
          ),
        );
      },
    );
  }

  bool _hasLatex(String text) {
    return text.contains(r'$') ||
        text.contains(r'\(') ||
        text.contains(r'\[') ||
        text.contains(r'\\') ||
        text.contains(r'\begin') ||
        text.contains(r'\frac') ||
        text.contains(r'\sqrt') ||
        text.contains(r'\alpha') ||
        text.contains(r'\beta') ||
        text.contains(r'\gamma') ||
        text.contains(r'\delta') ||
        text.contains(r'\theta') ||
        text.contains(r'\pi') ||
        text.contains(r'\sigma') ||
        text.contains(r'\omega') ||
        text.contains(r'\times') ||
        text.contains(r'\div') ||
        text.contains(r'\pm') ||
        text.contains(r'\neq') ||
        text.contains(r'\leq') ||
        text.contains(r'\geq');
  }
}

class ZoomedMathDialog extends StatefulWidget {
  final String formula;
  final Color textColor;
  final double baseFontSize;

  const ZoomedMathDialog({
    super.key,
    required this.formula,
    required this.textColor,
    required this.baseFontSize,
  });

  @override
  State<ZoomedMathDialog> createState() => _ZoomedMathDialogState();
}

class _ZoomedMathDialogState extends State<ZoomedMathDialog> {
  double _zoomLevel = 3.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Math Expression',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                // Zoom controls
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _zoomLevel > 1.0
                            ? () {
                                setState(() {
                                  _zoomLevel =
                                      (_zoomLevel - 0.5).clamp(1.0, 6.0);
                                });
                              }
                            : null,
                        icon: const Icon(Icons.zoom_out),
                      ),
                      Text(
                        '${(_zoomLevel * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium,
                      ),
                      IconButton(
                        onPressed: _zoomLevel < 6.0
                            ? () {
                                setState(() {
                                  _zoomLevel =
                                      (_zoomLevel + 0.5).clamp(1.0, 6.0);
                                });
                              }
                            : null,
                        icon: const Icon(Icons.zoom_in),
                      ),
                    ],
                  ),
                ),

                // Math content
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Center(
                        child: TeX2SVG(
                          math: widget.formula,
                          formulaWidgetBuilder: (context, svg) {
                            return SvgPicture.string(
                              svg,
                              colorFilter: ColorFilter.mode(
                                widget.textColor,
                                BlendMode.srcIn,
                              ),
                              height: widget.baseFontSize * _zoomLevel * 2,
                              fit: BoxFit.contain,
                              alignment: Alignment.center,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Footer with instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Tap outside to close • Use zoom controls to resize',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
