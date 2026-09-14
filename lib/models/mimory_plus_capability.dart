/// Subscription and purchase duration type
enum MimoryPurchaseType {
  monthly,
  yearly,
  lifetime,
  unknown,
}

/// Visual category for storybook capability cards
enum CapabilityIconType {
  worlds,
  environments,
  companions,
  echoes,
}

/// Single source of truth for MIMORY+ premium capabilities.
///
/// Ensures the application NEVER advertises future or placeholder features
/// as currently unlocked. Only capabilities with [implemented] == true
/// can be presented to the user.
class MimoryPlusCapability {
  final String id;
  final String title;
  final String description;
  final bool availableForPlus;
  final bool implemented;
  final CapabilityIconType iconType;

  const MimoryPlusCapability({
    required this.id,
    required this.title,
    required this.description,
    required this.availableForPlus,
    required this.implemented,
    required this.iconType,
  });

  /// All cataloged capabilities of MIMORY
  static const List<MimoryPlusCapability> all = [
    MimoryPlusCapability(
      id: 'premium_worlds',
      title: 'Premium Memory Worlds',
      description: 'Create more little worlds for everyone you love.',
      availableForPlus: true,
      implemented: true,
      iconType: CapabilityIconType.worlds,
    ),
    MimoryPlusCapability(
      id: 'living_environments',
      title: 'Advanced Living Environments',
      description: 'Rain, snow, sunsets and starlit nights bring your worlds to life.',
      availableForPlus: true,
      implemented: true,
      iconType: CapabilityIconType.environments,
    ),
    MimoryPlusCapability(
      id: 'storybook_companions',
      title: 'Living Storybook Companions',
      description: 'Garden rabbits, hand-holding walks, and storybook moments together.',
      availableForPlus: true,
      implemented: true,
      iconType: CapabilityIconType.companions,
    ),
    MimoryPlusCapability(
      id: 'memory_echoes',
      title: 'Memory Echoes',
      description: 'Revisit auditory memories through ambient wind chimes.',
      availableForPlus: true,
      implemented: false, // Truthful: Roadmap capability not yet in active world
      iconType: CapabilityIconType.echoes,
    ),
  ];

  /// Genuinely implemented and active capabilities unlocked by MIMORY+
  static List<MimoryPlusCapability> get unlockedForPlus =>
      all.where((c) => c.availableForPlus && c.implemented).toList();
}
