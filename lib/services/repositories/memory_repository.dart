import 'package:mimory/models/memory.dart';

abstract class MemoryRepository {
  Future<List<Memory>> getMemories();
  Future<void> saveMemory(Memory memory);
  Future<void> deleteMemory(String id);
}

class LocalMemoryRepository implements MemoryRepository {
  final Map<String, Memory> _store = {};

  LocalMemoryRepository() {
    // Seed some mock memories
    _store['1'] = Memory(
      id: '1',
      worldId: 'world_1',
      type: MemoryType.story,
      title: 'Finally shipped it.',
      description: 'The feeling of getting the first release out was amazing.',
      memoryDate: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    );
    _store['2'] = Memory(
      id: '2',
      worldId: 'world_1',
      type: MemoryType.photo,
      title: 'First hackathon.',
      description: 'We stayed up all night and built something cool.',
      memoryDate: DateTime.now().subtract(const Duration(days: 10)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );
  }

  @override
  Future<List<Memory>> getMemories() async {
    final list = _store.values.toList();
    list.sort((a, b) => b.memoryDate.compareTo(a.memoryDate));
    return list;
  }

  @override
  Future<void> saveMemory(Memory memory) async {
    _store[memory.id] = memory;
  }

  @override
  Future<void> deleteMemory(String id) async {
    _store.remove(id);
  }
}
