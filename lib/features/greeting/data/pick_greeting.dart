import 'package:navyblue_app/features/greeting/data/%20greeting_catalog.dart';
import '../domain/greeting_message.dart';


String _injectName(String s, String name) => s.replaceAll('<Name>', name);

/// Deterministic daily selection: no network, no mood input.
/// Deterministic selection: rotates morning/afternoon/evening (3x per day).
GreetingMessage pickGreeting(
  String name, {
  DateTime? now,
  bool rotateByDayPart = true, // set false to go back to once-per-day
  int seed = 0, // quick A/B testing without changing time
}) {
  final d = now ?? DateTime.now();

  // date key (same day)
  final dateKey = '${d.year}-${d.month}-${d.day}';

  // morning / afternoon / evening
  final partKey = rotateByDayPart ? _dayPartKey(d) : 'allday';

  // stable, deterministic key
  final key = '${name.trim().toLowerCase()}::$dateKey::$partKey::$seed';
  final h = _fnv1a32(key);

  final buckets = GreetingCatalog.buckets;
  final bucket = buckets[h % buckets.length];
  final msg = bucket[(h ~/ buckets.length) % bucket.length];

  return GreetingMessage(
    l1: _injectName(msg.l1, name),
    l2: msg.l2,
    emoji: msg.emoji,
  );
}

/// Morning ends 11:59; Afternoon ends 17:59; else Evening.
String _dayPartKey(DateTime d,
    {int morningEndHour = 11, int afternoonEndHour = 17}) {
  final h = d.hour;
  if (h <= morningEndHour) return 'morning';
  if (h <= afternoonEndHour) return 'afternoon';
  return 'evening';
}

/// Stable FNV-1a 32-bit hash (deterministic across runs/devices).
int _fnv1a32(String s) {
  const int fnvOffset = 0x811C9DC5;
  const int fnvPrime = 0x01000193;
  int hash = fnvOffset;
  for (int i = 0; i < s.length; i++) {
    hash ^= s.codeUnitAt(i);
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash & 0x7FFFFFFF;
}

