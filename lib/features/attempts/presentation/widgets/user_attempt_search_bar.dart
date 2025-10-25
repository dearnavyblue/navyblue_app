// lib/features/attempts/presentation/widgets/user_attempt_search_bar.dart
import 'package:flutter/material.dart';

class UserAttemptSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const UserAttemptSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<UserAttemptSearchBar> createState() => _UserAttemptSearchBarState();
}

class _UserAttemptSearchBarState extends State<UserAttemptSearchBar> {
  final TextEditingController _controller = TextEditingController();

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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _controller,
        style: theme.textTheme.bodyMedium,
        onChanged: (value) {
          widget.onSearch(value);
        },
        decoration: InputDecoration(
          hintText: 'Search by paper title, subject...',
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}