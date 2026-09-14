import 'package:flutter/material.dart';

/// Represents a persistent living anime character inhabiting a MIMORY World.
class Character {
  final String id;
  final String worldId;
  final String personName;
  final String gender; // 'male', 'female', 'other'
  final String? photoPath;
  final String animeStyle;
  final String hairStyle;
  final Color hairColor;
  final Color skinTone;
  final Color outfitColor;
  final bool isCurrentUser;

  Character({
    required this.id,
    required this.worldId,
    required this.personName,
    required this.gender,
    this.photoPath,
    this.animeStyle = 'storybook_chibi',
    required this.hairStyle,
    required this.hairColor,
    required this.skinTone,
    required this.outfitColor,
    this.isCurrentUser = false,
  });
}
