import 'package:hive/hive.dart';
import 'package:pocket_ssh/models/shortcut_model.dart';

class ShortcutsRepository {
  static const String _boxName = 'shortcuts';
  late Box<ShortcutModel> _box;

  // =========================
  // INIT
  // =========================
  Future<void> init() async {
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<ShortcutModel>(_boxName);
    } else {
      _box = await Hive.openBox<ShortcutModel>(_boxName);
    }
  }

  // =========================
  // READ
  // =========================
  List<ShortcutModel> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  // =========================
  // CREATE
  // =========================
  Future<void> add(ShortcutModel shortcut) async {
    await _box.put(shortcut.id, shortcut);
  }

  // =========================
  // UPDATE
  // =========================
  Future<void> update(ShortcutModel shortcut) async {
    await _box.put(shortcut.id, shortcut);
  }

  // =========================
  // DELETE
  // =========================
  Future<void> remove(String id) async {
    await _box.delete(id);
  }

  // =========================
  // SAVE ORDER (DRAG & DROP)
  // =========================
  Future<void> saveOrder(List<ShortcutModel> ordered) async {
    for (int i = 0; i < ordered.length; i++) {
      ordered[i].order = i;
      await ordered[i].save(); // 👈 HiveObject
    }
  }
}
