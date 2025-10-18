class GreetingMessage {
  final String l1; // short headline, must include <Name> before interpolation
  final String? l2; // optional subline (very short)
  final String emoji; // exactly one emoji (guardrail)
  const GreetingMessage({required this.l1, this.l2, required this.emoji});
}
