import 'package:flutter/material.dart';

enum PillVariant { filled, outline, subtle }

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.variant = PillVariant.outline,
    this.onTap,
    this.leading,
    this.trailing,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
  });

  final String label;
  final PillVariant variant;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? textColor;
  final Color? backgroundColor;
  final Color? borderColor;

  static const _height = 32.0;
  static const _padding = EdgeInsets.symmetric(horizontal: 14, vertical: 6);
  static const _radius = 20.0;

  static _PillColors _resolveColors(
    ThemeData theme,
    PillVariant variant, {
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
  }) {
    final base = () {
      switch (variant) {
        case PillVariant.filled:
          return _PillColors(
            backgroundColor: Colors.black.withValues(alpha: 0.9),
            textColor: Colors.white,
            border: null,
          );
        case PillVariant.subtle:
          return _PillColors(
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.15),
            textColor: theme.colorScheme.onSurface,
            border: null,
          );
        case PillVariant.outline:
          return _PillColors(
            backgroundColor: Colors.white,
            textColor: theme.colorScheme.onSurface,
            border: Border.fromBorderSide(
              const BorderSide(
                color: Color(0xFFE6E6E6),
              ),
            ),
          );
      }
    }();

    return base.copyWith(
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(
      Theme.of(context),
      variant,
      backgroundColor: backgroundColor,
      textColor: textColor,
      borderColor: borderColor,
    );

    final text = Flexible(
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
          color: colors.textColor,
        ),
      ),
    );

    final children = <Widget>[
      if (leading != null) ...[
        IconTheme(
          data: IconThemeData(size: 16, color: colors.iconColor),
          child: leading!,
        ),
        const SizedBox(width: 8),
      ],
      text,
      if (trailing != null) ...[
        const SizedBox(width: 8),
        IconTheme(
          data: IconThemeData(size: 14, color: colors.iconColor),
          child: trailing!,
        ),
      ],
    ];

    Widget content = Container(
      constraints: const BoxConstraints(minHeight: _height),
      padding: _padding,
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(_radius),
        border: colors.border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}

class PillDropdown<T> extends StatelessWidget {
  const PillDropdown({
    super.key,
    required this.items,
    required this.value,
    required this.hint,
    required this.labelBuilder,
    required this.onChanged,
    this.variant = PillVariant.outline,
    this.includeAllOption = true,
    this.leading,
  });

  final List<T> items;
  final T? value;
  final String hint;
  final String Function(T item) labelBuilder;
  final ValueChanged<T?> onChanged;
  final PillVariant variant;
  final bool includeAllOption;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = Pill._resolveColors(
      Theme.of(context),
      variant,
    );

    final textStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: colors.textColor,
    );

    final entries = includeAllOption ? [null, ...items] : [...items];

    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: colors.border,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          isDense: true,
          isExpanded: false,
          icon: Icon(Icons.expand_more,
              size: 18, color: colors.iconColor ?? colors.textColor),
          dropdownColor: Colors.white,
          style: textStyle,
          hint: _buildLabel(
              textStyle, value == null ? hint : labelBuilder(value as T)),
          selectedItemBuilder: (context) {
            return entries.map((entry) {
              final text = entry == null ? hint : labelBuilder(entry);
              return _buildLabel(textStyle, text);
            }).toList();
          },
          items: entries.map((entry) {
            final display = entry == null ? hint : labelBuilder(entry as T);
            return DropdownMenuItem<T?>(
              value: entry,
              child: _buildLabel(
                textStyle.copyWith(color: Colors.black),
                display,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildLabel(TextStyle textStyle, String text) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(size: 16, color: textStyle.color),
              child: leading!,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              text,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillColors {
  const _PillColors({
    required this.backgroundColor,
    required this.textColor,
    this.border,
  });

  final Color backgroundColor;
  final Color textColor;
  final BoxBorder? border;

  Color? get iconColor => textColor;

  _PillColors copyWith({
    Color? backgroundColor,
    Color? textColor,
    BoxBorder? border,
    Color? borderColor,
  }) {
    final resolvedBorder = border ??
        (borderColor == null
            ? this.border
            : Border.fromBorderSide(BorderSide(color: borderColor)));
    return _PillColors(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      border: resolvedBorder,
    );
  }
}
