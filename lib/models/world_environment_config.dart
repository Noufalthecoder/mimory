import 'package:flutter/material.dart';

/// Time of day states for the dynamic storybook world.
enum TimeOfDayState {
  morning,
  day,
  sunset,
  night;

  String get label {
    switch (this) {
      case TimeOfDayState.morning:
        return 'Morning ☀️';
      case TimeOfDayState.day:
        return 'Day 🌤️';
      case TimeOfDayState.sunset:
        return 'Sunset 🌅';
      case TimeOfDayState.night:
        return 'Night 🌙';
    }
  }
}

/// Weather and atmospheric conditions.
enum WorldCondition {
  sunny,
  rain,
  snow;

  String get label {
    switch (this) {
      case WorldCondition.sunny:
        return 'Clear ✨';
      case WorldCondition.rain:
        return 'Rain 🌧️';
      case WorldCondition.snow:
        return 'Snow ❄️';
    }
  }
}

/// Seasonal state for organic environmental touches.
enum SeasonState {
  spring,
  summer,
  autumn,
  winter;

  String get label {
    switch (this) {
      case SeasonState.spring:
        return 'Spring 🌸';
      case SeasonState.summer:
        return 'Summer 🌻';
      case SeasonState.autumn:
        return 'Autumn 🍂';
      case SeasonState.winter:
        return 'Winter ⛄';
    }
  }
}

/// Comprehensive environment configuration for the Living World.
class WorldEnvironmentConfig {
  final String worldStyle; // 'cozy_town', 'starlit_forest', 'blooming_meadow', 'sunlit_valley'
  final TimeOfDayState timeOfDay;
  final WorldCondition condition;
  final SeasonState season;
  final int memoryCount;

  const WorldEnvironmentConfig({
    this.worldStyle = 'cozy_town',
    this.timeOfDay = TimeOfDayState.day,
    this.condition = WorldCondition.sunny,
    this.season = SeasonState.spring,
    this.memoryCount = 0,
  });

  /// Factory creating natural environment based on current real-world clock time.
  factory WorldEnvironmentConfig.fromNaturalTime({
    required String worldStyle,
    required int memoryCount,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final month = now.month;

    // Time of day detection
    final TimeOfDayState timeOfDay;
    if (hour >= 5 && hour < 10) {
      timeOfDay = TimeOfDayState.morning;
    } else if (hour >= 10 && hour < 17) {
      timeOfDay = TimeOfDayState.day;
    } else if (hour >= 17 && hour < 20) {
      timeOfDay = TimeOfDayState.sunset;
    } else {
      timeOfDay = TimeOfDayState.night;
    }

    // Season detection
    final SeasonState season;
    if (month >= 3 && month <= 5) {
      season = SeasonState.spring;
    } else if (month >= 6 && month <= 8) {
      season = SeasonState.summer;
    } else if (month >= 9 && month <= 11) {
      season = SeasonState.autumn;
    } else {
      season = SeasonState.winter;
    }

    // Default sunny condition naturally, or snow if winter
    final condition = (season == SeasonState.winter)
        ? WorldCondition.snow
        : WorldCondition.sunny;

    return WorldEnvironmentConfig(
      worldStyle: worldStyle,
      timeOfDay: timeOfDay,
      condition: condition,
      season: season,
      memoryCount: memoryCount,
    );
  }

  WorldEnvironmentConfig copyWith({
    String? worldStyle,
    TimeOfDayState? timeOfDay,
    WorldCondition? condition,
    SeasonState? season,
    int? memoryCount,
  }) {
    return WorldEnvironmentConfig(
      worldStyle: worldStyle ?? this.worldStyle,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      condition: condition ?? this.condition,
      season: season ?? this.season,
      memoryCount: memoryCount ?? this.memoryCount,
    );
  }

  // --- Aesthetic Lighting & Color Tokens ---

  /// Sky Gradient colors for the background canvas.
  List<Color> get skyColors {
    if (condition == WorldCondition.rain) {
      // Overcast soft storybook rain sky
      return const [
        Color(0xFFD3DDE6), // Misty cloud slate
        Color(0xFFB8C8D4), // Soft rain blue
        Color(0xFFA8BCCB), // Atmospheric horizon mist
      ];
    }

    if (condition == WorldCondition.snow) {
      // Winter frosted sky
      return const [
        Color(0xFFEFF5FB), // Powder frost white
        Color(0xFFD6E4F0), // Cool winter mist
        Color(0xFFC5D7E8), // Distant horizon
      ];
    }

    switch (timeOfDay) {
      case TimeOfDayState.morning:
        return const [
          Color(0xFFFFF9F0), // Soft dawn cream
          Color(0xFFFFEEE4), // Pastel peach glow
          Color(0xFFF6E7DE), // Dew horizon
        ];
      case TimeOfDayState.day:
        return const [
          Color(0xFFF4F9FF), // Clear soft blue
          Color(0xFFFFF7EC), // Warm midday sun cream
          Color(0xFFF1F6EC), // Meadow horizon reflection
        ];
      case TimeOfDayState.sunset:
        return const [
          Color(0xFFFFB37E), // Golden amber orange
          Color(0xFFFF8B80), // Rose twilight
          Color(0xFFC06C84), // Deep dusk horizon
        ];
      case TimeOfDayState.night:
        return const [
          Color(0xFF191F38), // Deep indigo midnight
          Color(0xFF222B4C), // Storybook royal navy
          Color(0xFF333E64), // Horizon twilight
        ];
    }
  }

  /// Distant Mountains / Horizon Hill Tint
  Color get mountainColor {
    if (condition == WorldCondition.rain) {
      return const Color(0xFF8DA4B5).withValues(alpha: 0.70);
    }
    if (condition == WorldCondition.snow) {
      return const Color(0xFFB8CEDB).withValues(alpha: 0.85);
    }

    switch (timeOfDay) {
      case TimeOfDayState.morning:
        return const Color(0xFFC7DEC4).withValues(alpha: 0.75);
      case TimeOfDayState.day:
        return const Color(0xFFB2D4AE).withValues(alpha: 0.70);
      case TimeOfDayState.sunset:
        return const Color(0xFF8B5E6D).withValues(alpha: 0.80);
      case TimeOfDayState.night:
        return const Color(0xFF1E2845).withValues(alpha: 0.90);
    }
  }

  /// Meadow Ground Grass Colors (Far, Mid, Fore)
  List<Color> get meadowGrassColors {
    if (condition == WorldCondition.snow) {
      // Snow-frosted ground with visible soft green undertones
      return const [
        Color(0xFFE4EFF5), // Far snow crest
        Color(0xFFD4E5ED), // Mid snow knoll
        Color(0xFFC5DBE5), // Fore snow ground
      ];
    }

    if (condition == WorldCondition.rain) {
      // Lush, wet darker green
      return const [
        Color(0xFF6B9966),
        Color(0xFF5A8456),
        Color(0xFF4C7548),
      ];
    }

    if (season == SeasonState.autumn) {
      // Golden autumn meadow
      return const [
        Color(0xFFCFAC62),
        Color(0xFFBD974E),
        Color(0xFFA67F3A),
      ];
    }

    switch (timeOfDay) {
      case TimeOfDayState.morning:
        return const [
          Color(0xFF98CA92),
          Color(0xFF82B57B),
          Color(0xFF73A76C),
        ];
      case TimeOfDayState.day:
        return const [
          Color(0xFF90C28A),
          Color(0xFF7CAE74),
          Color(0xFF6E9F65),
        ];
      case TimeOfDayState.sunset:
        return const [
          Color(0xFF99815A),
          Color(0xFF856A43),
          Color(0xFF6E5331),
        ];
      case TimeOfDayState.night:
        return const [
          Color(0xFF2C4336),
          Color(0xFF23372B),
          Color(0xFF1B2B22),
        ];
    }
  }

  /// Road surface color
  Color get roadColor {
    if (condition == WorldCondition.snow) {
      return const Color(0xFFEBF2F7);
    }
    if (condition == WorldCondition.rain) {
      // Wet reflective cobblestone
      return const Color(0xFFD6CFC4);
    }
    switch (timeOfDay) {
      case TimeOfDayState.morning:
        return const Color(0xFFFAF5EC);
      case TimeOfDayState.day:
        return const Color(0xFFF5EFE4);
      case TimeOfDayState.sunset:
        return const Color(0xFFE8D3BD);
      case TimeOfDayState.night:
        return const Color(0xFF4E4E58);
    }
  }

  /// Road border color
  Color get roadBorderColor {
    if (condition == WorldCondition.snow) {
      return const Color(0xFFC8D9E6);
    }
    if (condition == WorldCondition.rain) {
      return const Color(0xFFA89C8A);
    }
    switch (timeOfDay) {
      case TimeOfDayState.night:
        return const Color(0xFF383842);
      default:
        return const Color(0xFFC7BAA5);
    }
  }

  /// Ambient overlay color for whole scene lighting tint
  Color? get ambientLightOverlayColor {
    switch (timeOfDay) {
      case TimeOfDayState.morning:
        return const Color(0xFFFFECC4).withValues(alpha: 0.08);
      case TimeOfDayState.day:
        return null;
      case TimeOfDayState.sunset:
        return const Color(0xFFFF8B4A).withValues(alpha: 0.18);
      case TimeOfDayState.night:
        return const Color(0xFF0F172E).withValues(alpha: 0.32);
    }
  }

  /// Tree foliage back & front colors
  (Color, Color) get treeFoliageColors {
    if (condition == WorldCondition.snow) {
      return (const Color(0xFF9FBECB), const Color(0xFFB8D5E3));
    }
    if (season == SeasonState.autumn) {
      return (const Color(0xFFBF5F34), const Color(0xFFD97D43));
    }
    if (condition == WorldCondition.rain) {
      return (const Color(0xFF4E773D), const Color(0xFF5E874C));
    }
    switch (timeOfDay) {
      case TimeOfDayState.night:
        return (const Color(0xFF1E392B), const Color(0xFF284A38));
      case TimeOfDayState.sunset:
        return (const Color(0xFF7A6B3D), const Color(0xFF948149));
      default:
        return (const Color(0xFF6B9955), const Color(0xFF7FA86D));
    }
  }

  /// Whether cozy window / lantern lights should glow
  bool get areLightsGlowing =>
      timeOfDay == TimeOfDayState.sunset || timeOfDay == TimeOfDayState.night;
}
