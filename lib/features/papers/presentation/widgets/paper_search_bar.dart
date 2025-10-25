import 'package:flutter/material.dart';

class PaperSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? initialQuery;

  const PaperSearchBar({
    super.key,
    required this.onSearch,
    this.initialQuery,
  });

  @override
  State<PaperSearchBar> createState() => _PaperSearchBarState();
}

class _PaperSearchBarState extends State<PaperSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8)
      ),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search papers...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          isDense: true,
        ),
        onChanged: (value) {
          setState(() {});
          // Debounce search to avoid too many API calls
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_controller.text == value) {
              widget.onSearch(value);
            }
          });
        },
        onSubmitted: widget.onSearch,
      ),
    );
  }
}
