import 'package:flutter/material.dart';

class AttemptAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AttemptAppBar({
    super.key,
    required this.selectedIndex,
    required this.memoEnabled,
    required this.onChanged,
    required this.isExamMode,
    required this.isTimerRunning,
    required this.remainingSeconds,
    required this.isPracticeMode,
    required this.canShowHints,
    required this.onToggleHints,
    required this.isOffline,
  });

  final int selectedIndex;
  final bool memoEnabled;
  final ValueChanged<int> onChanged;

  final bool isExamMode;
  final bool isTimerRunning;
  final int? remainingSeconds;

  final bool isPracticeMode;
  final bool canShowHints;
  final VoidCallback onToggleHints;

  final bool isOffline;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: true, // normal back button
      centerTitle: true,
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      elevation: 0,
      title: _AttemptCenterSwitcher(
        selectedIndex: selectedIndex,
        memoEnabled: memoEnabled,
        onChanged: onChanged,
      ),
      // Keep functionality; only visuals adjusted
      actions: [
        if (isOffline)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Offline',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (isExamMode && isTimerRunning)
          _ExamTimerChip(remainingSeconds: remainingSeconds ?? 0)
        else if (isPracticeMode)
          IconButton(
            icon:
                Icon(canShowHints ? Icons.lightbulb : Icons.lightbulb_outline),
            onPressed: onToggleHints,
            tooltip: 'Assist Mode',
          ),
      ],
    );
  }
}

class _AttemptCenterSwitcher extends StatelessWidget {
  const _AttemptCenterSwitcher({
    required this.selectedIndex,
    required this.memoEnabled,
    required this.onChanged,
  });

  final int selectedIndex;
  final bool memoEnabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Spec colors
    const activeBg = Colors.black;
    const activeFg = Colors.white;
    final inactiveBg = Colors.grey.shade200;
    final inactiveFg = Colors.grey.shade700;

    // We draw the rounded "pill" ourselves behind the SegmentedButton.
    // The SegmentedButton itself gets a transparent background, so the pill
    // shows through and remains fully rounded on ALL sides.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 34, // align height with filters
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1) Light grey capsule container
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: inactiveBg,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // 2) Sliding black pill behind the selected segment
            Positioned.fill(
              child: AnimatedAlign(
                alignment: selectedIndex == 0
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5, // two segments -> half width
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: activeBg,
                      borderRadius: BorderRadius.circular(20), // fully rounded
                    ),
                  ),
                ),
              ),
            ),
            // 3) SegmentedButton (transparent background, text colors only)
            Theme(
              data: theme.copyWith(
                segmentedButtonTheme: SegmentedButtonThemeData(
                  style: ButtonStyle(
                    shape: const MaterialStatePropertyAll(StadiumBorder()),
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    // transparent so our custom pill is visible
                    backgroundColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    side: const MaterialStatePropertyAll(
                        BorderSide(color: Colors.transparent)),
                    overlayColor:
                        const MaterialStatePropertyAll(Colors.transparent),
                    // set label colors to contrast with our backgrounds
                    foregroundColor:
                        MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.disabled)) {
                        return inactiveFg;
                      }
                      final selected =
                          states.contains(MaterialState.selected);
                      return selected ? activeFg : inactiveFg;
                    }),
                  ),
                ),
              ),
              child: SegmentedButton<int>(
                multiSelectionEnabled: false,
                showSelectedIcon: false,
                segments: <ButtonSegment<int>>[
                  const ButtonSegment<int>(value: 0, label: Text('Paper')),
                  // keep enabled + guard so behavior stays unchanged
                  ButtonSegment<int>(
                    value: 1,
                    label: const Text('Memo'),
                    enabled: memoEnabled,
                  ),
                ],
                selected: {selectedIndex.clamp(0, 1)},
                onSelectionChanged: (set) {
                  final value = set.first;
                  if (value == 1 && !memoEnabled) return; // safety guard
                  onChanged(value);
                },
              ),
            ),
            // 4) Tooltip overlay when Memo is locked (purely visual)
            if (!memoEnabled)
              FractionallySizedBox(
                widthFactor: 0.5,
                alignment: Alignment.centerRight,
                child: Tooltip(
                  message: 'Available after exam time',
                  preferBelow: false,
                  waitDuration: const Duration(milliseconds: 250),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap:
                        () {}, // swallow taps, show only tooltip on long-press/hover
                    onLongPress: () {}, // (hover shows tooltip on desktop)
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExamTimerChip extends StatelessWidget {
  const _ExamTimerChip({required this.remainingSeconds});
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final isLow = remainingSeconds < 300; // < 5 min
    final bg = isLow ? Colors.red[100] : Colors.grey[100];
    final fg = isLow ? Colors.red[700] : Colors.grey[700];

    String _format(int s) {
      final h = s ~/ 3600;
      final m = (s % 3600) ~/ 60;
      final ss = s % 60;
      return h > 0
          ? '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}'
          : '${m.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20), // capsule
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(_format(remainingSeconds),
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.normal, color: fg)),
        ],
      ),
    );
  }
}
