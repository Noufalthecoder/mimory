import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:mimory/models/user_session.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';

/// Handles persistent local storage for MIMORY:
/// 1. User Session (persisted across restarts, cleared on logout)
/// 2. Worlds (persisted indefinitely, never cleared on logout)
/// 3. Memories (persisted indefinitely, linked via memory.worldId)
/// 4. Photos (copied into app-controlled persistent document storage)
class StorageService {
  static const String _keySession = 'mimory_user_session';
  static const String _keyWorlds = 'mimory_worlds';
  static const String _keyMemories = 'mimory_memories';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final Uuid _uuid = const Uuid();

  /// Saves the current user session (null to clear)
  Future<void> saveSession(UserSession? session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (session == null) {
        await prefs.remove(_keySession);
      } else {
        await prefs.setString(_keySession, jsonEncode(session.toJson()));
      }
    } catch (e) {
      debugPrint('StorageService: Error saving session: $e');
    }
  }

  /// Loads the persisted user session
  Future<UserSession?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keySession);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserSession.fromJson(data);
      }
    } catch (e) {
      debugPrint('StorageService: Error loading session: $e');
    }
    return null;
  }

  /// Clears only the session (retains worlds & memories)
  Future<void> clearSession() async {
    await saveSession(null);
  }

  /// Saves all worlds to persistent storage
  Future<void> saveWorlds(List<World> worlds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = worlds.map((w) => w.toJson()).toList();
      await prefs.setString(_keyWorlds, jsonEncode(list));
    } catch (e) {
      debugPrint('StorageService: Error saving worlds: $e');
    }
  }

  /// Loads all persisted worlds
  Future<List<World>> loadWorlds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyWorlds);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list
            .map((item) => World.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('StorageService: Error loading worlds: $e');
    }
    return [];
  }

  /// Saves all memories to persistent storage
  Future<void> saveMemories(List<Memory> memories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = memories.map((m) => m.toJson()).toList();
      await prefs.setString(_keyMemories, jsonEncode(list));
    } catch (e) {
      debugPrint('StorageService: Error saving memories: $e');
    }
  }

  /// Loads all persisted memories
  Future<List<Memory>> loadMemories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_keyMemories);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final list = jsonDecode(jsonStr) as List<dynamic>;
        return list
            .map((item) => Memory.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('StorageService: Error loading memories: $e');
    }
    return [];
  }

  /// Copies an image file into an app-controlled persistent directory so it survives app restarts.
  /// Returns the persistent file path.
  Future<String> persistPhoto(String tempPath) async {
    try {
      final file = File(tempPath);
      if (!await file.exists()) {
        return tempPath;
      }

      final docDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${docDir.path}/mimory_photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final ext = tempPath.contains('.') ? tempPath.split('.').last : 'jpg';
      final fileName = 'mimory_${_uuid.v4()}.$ext';
      final persistentFile = await file.copy('${photosDir.path}/$fileName');
      return persistentFile.path;
    } catch (e) {
      debugPrint('StorageService: Error persisting photo: $e');
      return tempPath;
    }
  }

  /// Clear all data (for test fixtures or testing reset)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySession);
      await prefs.remove(_keyWorlds);
      await prefs.remove(_keyMemories);
    } catch (e) {
      debugPrint('StorageService: Error clearing all data: $e');
    }
  }
}
