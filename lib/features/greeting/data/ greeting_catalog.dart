import '../domain/greeting_message.dart';

/// Guardrails: short, positive, max 1 emoji, <Name> token for natural flow.
class GreetingCatalog {
  static const cheeky = <GreetingMessage>[
    GreetingMessage(
        l1: "Look who’s back, <Name>.",
        l2: "Let’s get a quick win.",
        emoji: "🙂"),
    GreetingMessage(
        l1: "Eish <Name>, papers missed you.",
        l2: "One page at a time.",
        emoji: "😏"),
    GreetingMessage(
        l1: "Yoh <Name>, we cooking today?",
        l2: "Just one task to start.",
        emoji: "😎"),
  ];

  static const funny = <GreetingMessage>[
    GreetingMessage(
        l1: "Eish <Name>, these won’t do themselves.",
        l2: "We got this.",
        emoji: "😂"),
    GreetingMessage(
        l1: "Breaking news: <Name> logged in.",
        l2: "Sources: us.",
        emoji: "📰"),
    GreetingMessage(
        l1: "Okay <Name>, round two with the notes.",
        l2: "Bell’s already rung.",
        emoji: "🥊"),
  ];

  static const hype = <GreetingMessage>[
    GreetingMessage(
        l1: "Ayy <Name>, main character energy.",
        l2: "Start strong.",
        emoji: "⚡"),
    GreetingMessage(
        l1: "Yooo <Name>! The GOAT pulled up.", l2: "Cook time.", emoji: "🔥"),
    GreetingMessage(
        l1: "Sharp <Name>, champion mode on.",
        l2: "Bang the first task.",
        emoji: "👑"),
  ];

  static const calm = <GreetingMessage>[
    GreetingMessage(
        l1: "Good to see you, <Name>.",
        l2: "Deep breath, let’s begin.",
        emoji: "🌿"),
    GreetingMessage(
        l1: "Welcome back, <Name>.", l2: "One page at a time.", emoji: "📖"),
    GreetingMessage(
        l1: "Nice to have you here, <Name>.",
        l2: "Focus beats speed.",
        emoji: "🎯"),
  ];

  static const buckets = [cheeky, funny, hype, calm];
}
