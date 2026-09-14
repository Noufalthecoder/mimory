import 'package:uuid/uuid.dart';
import 'package:mimory/models/world.dart';
import 'package:mimory/models/memory.dart';
import 'package:mimory/models/character.dart';
import 'package:mimory/models/user_session.dart';
import 'package:mimory/models/avatar_definition.dart';
import 'package:mimory/services/storage_service.dart';
import 'package:mimory/services/revenue_cat_service.dart';

class WorldService {
  // Singleton pattern
  static final WorldService _instance = WorldService._internal();
  factory WorldService() => _instance;
  WorldService._internal();

  final Uuid _uuid = const Uuid();
  final StorageService _storage = StorageService();

  UserSession? _session;
  final List<World> _worlds = [];
  final List<Character> _characters = [];
  final List<Memory> _memories = [];

  bool _isInitialized = false;

  /// Loads persisted session, worlds, and memories from disk
  Future<void> init() async {
    if (_isInitialized) return;

    _session = await _storage.loadSession();
    final savedWorlds = await _storage.loadWorlds();
    final savedMemories = await _storage.loadMemories();

    _worlds.clear();
    _worlds.addAll(savedWorlds);

    _characters.clear();
    for (final world in _worlds) {
      _initializeCharactersForWorld(world);
    }

    _memories.clear();
    _memories.addAll(savedMemories);

    _isInitialized = true;
  }

  // ==========================================
  // SESSION / MOCK AUTHENTICATION
  // ==========================================

  bool get isLoggedIn => _session?.isLoggedIn ?? false;
  UserSession? get session => _session;

  /// Current user profile defaults
  String get currentUserName => _session?.displayName ?? 'Noufal';
  String get currentUserEmail => _session?.email ?? 'noufal@mimory.app';

  /// Simulates a Google Sign-In and persists the mock session
  Future<UserSession> loginWithGoogle() async {
    final user = UserSession(
      id: 'mock_user_001',
      displayName: 'Noufal',
      email: 'noufal@mimory.app',
      isLoggedIn: true,
    );
    _session = user;
    await _storage.saveSession(user);
    await RevenueCatService().logIn(user.id);
    return user;
  }

  /// Simulates an Email Sign-In and persists the mock session
  Future<UserSession> loginWithEmail(String email) async {
    String name = 'Friend';
    final trimmed = email.trim();
    if (trimmed.contains('@')) {
      final part = trimmed.split('@').first;
      if (part.isNotEmpty) {
        name = part[0].toUpperCase() + (part.length > 1 ? part.substring(1) : '');
      }
    }

    final user = UserSession(
      id: 'mock_user_001',
      displayName: name,
      email: trimmed.isEmpty ? 'friend@mimory.app' : trimmed,
      isLoggedIn: true,
    );
    _session = user;
    await _storage.saveSession(user);
    await RevenueCatService().logIn(user.id);
    return user;
  }

  /// Clears only the current session.
  /// KEEPS worlds, memories, and photos.
  Future<void> logout() async {
    _session = null;
    await _storage.clearSession();
    await RevenueCatService().logOut();
  }

  // ==========================================
  // WORLD MANAGEMENT
  // ==========================================

  List<World> get worlds => List.unmodifiable(_worlds);

  World? getWorld(String worldId) {
    try {
      return _worlds.firstWhere((w) => w.id == worldId);
    } catch (_) {
      return null;
    }
  }

  /// Generates a unique ID, creates a new World, initializes its characters,
  /// and immediately persists it to local storage.
  Future<World> createWorld({
    required String name,
    required String relationshipType,
    required String personName,
    String? nickname,
    String? personPhotoPath,
    String? personGender,
    String userAvatarId = 'boy_01',
    String companionAvatarId = 'girl_01',
    String worldStyle = 'cozy_town',
  }) async {
    String? storedPhotoPath = personPhotoPath;
    if (personPhotoPath != null && personPhotoPath.isNotEmpty) {
      storedPhotoPath = await _storage.persistPhoto(personPhotoPath);
    }

    final newWorld = World(
      id: _uuid.v4(),
      name: name,
      relationshipType: relationshipType,
      personName: personName,
      nickname: nickname,
      personPhotoPath: storedPhotoPath,
      personGender: personGender,
      userAvatarId: userAvatarId,
      companionAvatarId: companionAvatarId,
      worldStyle: worldStyle,
      createdAt: DateTime.now(),
    );

    _worlds.add(newWorld);

    // Create the persistent character pair for this world
    _initializeCharactersForWorld(newWorld);

    // Persist to disk
    await _storage.saveWorlds(_worlds);

    return newWorld;
  }

  /// Updates or saves an existing world
  Future<void> saveWorld(World world) async {
    final idx = _worlds.indexWhere((w) => w.id == world.id);
    if (idx >= 0) {
      _worlds[idx] = world;
    } else {
      _worlds.add(world);
      _initializeCharactersForWorld(world);
    }
    await _storage.saveWorlds(_worlds);
  }

  // ==========================================
  // CHARACTER MANAGEMENT
  // ==========================================

  List<Character> get characters => List.unmodifiable(_characters);

  void _initializeCharactersForWorld(World world) {
    // Remove existing characters for this world if re-initializing
    _characters.removeWhere((c) => c.worldId == world.id);

    // Person 1: User's chosen Avatar
    final userAvatar = AvatarDefinition.getById(world.userAvatarId);
    final userCharacter = userAvatar.toCharacter(
      id: '${world.id}_user',
      worldId: world.id,
      personName: currentUserName,
      isCurrentUser: true,
    );

    // Person 2: Relationship Companion's chosen Avatar
    final companionAvatar = AvatarDefinition.getById(world.companionAvatarId);
    final companionDisplayName =
        (world.nickname?.isNotEmpty == true) ? world.nickname! : world.personName;

    final companionCharacter = companionAvatar.toCharacter(
      id: '${world.id}_companion',
      worldId: world.id,
      personName: companionDisplayName,
      isCurrentUser: false,
      photoPath: world.personPhotoPath,
    );

    _characters.add(userCharacter);
    _characters.add(companionCharacter);
  }

  /// Retrieves the two persistent characters living inside this World
  List<Character> getCharactersForWorld(String worldId) {
    var worldChars = _characters.where((c) => c.worldId == worldId).toList();
    if (worldChars.isEmpty) {
      final world = _worlds.firstWhere(
        (w) => w.id == worldId,
        orElse: () => World(
          id: worldId,
          name: 'World',
          relationshipType: 'partner',
          personName: 'Companion',
          userAvatarId: 'boy_01',
          companionAvatarId: 'girl_01',
          worldStyle: 'cozy_town',
          createdAt: DateTime.now(),
        ),
      );
      _initializeCharactersForWorld(world);
      worldChars = _characters.where((c) => c.worldId == worldId).toList();
    }
    return worldChars;
  }

  // ==========================================
  // MEMORY MANAGEMENT
  // ==========================================

  List<Memory> get memories => List.unmodifiable(_memories);

  /// Generates a unique ID, creates a new Memory attached to worldId,
  /// persists image to persistent storage, and persists memory to local storage.
  Future<Memory> createMemory({
    required String worldId,
    required MemoryType type,
    required String title,
    required String description,
    String? imagePath,
    required DateTime memoryDate,
  }) async {
    String? storedImagePath = imagePath;
    if (imagePath != null && imagePath.isNotEmpty) {
      storedImagePath = await _storage.persistPhoto(imagePath);
    }

    final newMemory = Memory(
      id: _uuid.v4(),
      worldId: worldId,
      type: type,
      title: title,
      description: description,
      imagePath: storedImagePath,
      memoryDate: memoryDate,
      createdAt: DateTime.now(),
    );

    _memories.add(newMemory);

    // Persist to disk
    await _storage.saveMemories(_memories);

    return newMemory;
  }

  /// Retrieves all memories associated with a specific worldId, sorted by memoryDate descending
  List<Memory> getMemoriesForWorld(String worldId) {
    final worldMemories = _memories.where((m) => m.worldId == worldId).toList();
    worldMemories.sort((a, b) => b.memoryDate.compareTo(a.memoryDate));
    return worldMemories;
  }

  /// For automated testing or reset
  Future<void> clearAllDataForTesting() async {
    _session = null;
    _worlds.clear();
    _characters.clear();
    _memories.clear();
    await _storage.clearAll();
    _isInitialized = true;
  }
}
