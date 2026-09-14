import 'package:flutter/material.dart';
import 'package:mimory/models/character.dart';

/// Pre-made hand-painted anime/storybook avatar definitions for MIMORY.
class AvatarDefinition {
  final String id;
  final String name;
  final String gender; // 'female' or 'male'
  final String hairStyle;
  final Color hairColor;
  final Color skinTone;
  final Color outfitColor;
  final Color accentColor;
  final String description;

  const AvatarDefinition({
    required this.id,
    required this.name,
    required this.gender,
    required this.hairStyle,
    required this.hairColor,
    required this.skinTone,
    required this.outfitColor,
    required this.accentColor,
    required this.description,
  });

  /// Curated pre-made anime/storybook avatars
  static const List<AvatarDefinition> all = [
    // 1. Girl Avatar 01
    AvatarDefinition(
      id: 'girl_01',
      name: 'Hana',
      gender: 'female',
      hairStyle: 'twin_tails',
      hairColor: Color(0xFF5D4037), // Chestnut brown
      skinTone: Color(0xFFFFF0E1), // Soft ivory peach
      outfitColor: Color(0xFFF197A2), // Soft pastel rose hoodie
      accentColor: Color(0xFFEE6379),
      description: 'Twin tails & cozy rose sweater',
    ),
    // 2. Boy Avatar 01
    AvatarDefinition(
      id: 'boy_01',
      name: 'Ren',
      gender: 'male',
      hairStyle: 'short_fringe',
      hairColor: Color(0xFF3E2723), // Warm dark brown
      skinTone: Color(0xFFFFDFC4), // Soft peach
      outfitColor: Color(0xFF81A4CD), // Soft dusty blue sweater
      accentColor: Color(0xFF5C8CB8),
      description: 'Short fringe & dusty blue knit',
    ),
    // 3. Girl Avatar Variation 02
    AvatarDefinition(
      id: 'girl_02',
      name: 'Aoi',
      gender: 'female',
      hairStyle: 'wavy_bob',
      hairColor: Color(0xFF362419), // Dark chocolate
      skinTone: Color(0xFFFFF5EB), // Ivory peach
      outfitColor: Color(0xFF90C2A3), // Sage green sweater
      accentColor: Color(0xFF6B9A7D),
      description: 'Wavy bob & calm sage sweater',
    ),
    // 4. Boy Avatar Variation 02
    AvatarDefinition(
      id: 'boy_02',
      name: 'Haru',
      gender: 'male',
      hairStyle: 'side_part',
      hairColor: Color(0xFF2C3E50), // Soft charcoal
      skinTone: Color(0xFFFFF0E1), // Soft ivory
      outfitColor: Color(0xFFE5B068), // Warm amber sweater
      accentColor: Color(0xFFD49340),
      description: 'Side part & warm amber knit',
    ),
    // 5. Additional diverse girl avatar
    AvatarDefinition(
      id: 'girl_03',
      name: 'Yuki',
      gender: 'female',
      hairStyle: 'high_ponytail',
      hairColor: Color(0xFF6D4C41), // Honey amber brown
      skinTone: Color(0xFFFFF8EE), // Warm cream peach
      outfitColor: Color(0xFFB39DDB), // Soft lavender sweater
      accentColor: Color(0xFF9575CD),
      description: 'High ponytail & soft lavender knit',
    ),
    // 6. Additional diverse boy avatar
    AvatarDefinition(
      id: 'boy_03',
      name: 'Kaito',
      gender: 'male',
      hairStyle: 'messy_fringe',
      hairColor: Color(0xFF4E342E), // Auburn brown
      skinTone: Color(0xFFFFDFC4), // Peach tone
      outfitColor: Color(0xFF7CB342), // Forest olive sweater
      accentColor: Color(0xFF558B2F),
      description: 'Messy fringe & forest green knit',
    ),
  ];

  static AvatarDefinition getById(String id) {
    return all.firstWhere(
      (a) => a.id == id,
      orElse: () => all.first,
    );
  }

  /// Converts this avatar definition into a runtime Character instance
  Character toCharacter({
    required String id,
    required String worldId,
    required String personName,
    required bool isCurrentUser,
    String? photoPath,
  }) {
    return Character(
      id: id,
      worldId: worldId,
      personName: personName,
      gender: gender,
      photoPath: photoPath,
      hairStyle: hairStyle,
      hairColor: hairColor,
      skinTone: skinTone,
      outfitColor: outfitColor,
      isCurrentUser: isCurrentUser,
    );
  }
}
