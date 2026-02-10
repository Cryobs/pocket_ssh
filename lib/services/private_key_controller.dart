import 'package:flutter/foundation.dart';
import 'package:pocket_ssh/models/private_key.dart';
import 'package:pocket_ssh/services/private_key_repo.dart';

class PrivateKeyController extends ChangeNotifier {
  final PrivateKeyRepo repo;

  List<PrivateKey> get keys => repo.getAll();

  PrivateKeyController(this.repo);

  Future<void> addKey(PrivateKey key) async {
    await repo.save(key);
    notifyListeners();
  }

  Future<void> updateKey(PrivateKey key) async {
    await repo.save(key);
    notifyListeners();
  }

  Future<void> deleteKey(String id) async {
    await repo.delete(id);
    notifyListeners();
  }

  PrivateKey? getKey(String id) {
    return repo.getById(id);
  }
}