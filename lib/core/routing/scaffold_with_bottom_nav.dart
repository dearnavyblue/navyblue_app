import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({
    required this.navigationShell,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: theme.colorScheme.surface,
                indicatorColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                labelTextStyle: MaterialStateProperty.resolveWith(
                  (states) => theme.textTheme.labelMedium?.copyWith(
                    fontWeight: states.contains(MaterialState.selected)
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: states.contains(MaterialState.selected)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                iconTheme: MaterialStateProperty.resolveWith(
                  (states) => IconThemeData(
                    size: 22,
                    color: states.contains(MaterialState.selected)
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              child: NavigationBar(
                height: 64,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description),
                    label: 'Papers',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.more_horiz),
                    selectedIcon: Icon(Icons.more_horiz),
                    label: 'More',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
