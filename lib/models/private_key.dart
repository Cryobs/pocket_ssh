import "package:hive/hive.dart";

part "private_key.g.dart";

@HiveType(typeId: 0)
class PrivateKey extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String key;

  @HiveField(3)
  final String? passphrase;

  PrivateKey({
    required this.id,
    required this.name,
    required this.key,
    this.passphrase,
  });


  PrivateKey copyWith({
    String? id,
    String? name,
    String? key,
    String? passphrase
  }) {
    return PrivateKey(
        id: id ?? this.id,
        name: name ?? this.name,
        key: key ?? this.key,
        passphrase: passphrase ?? this.passphrase
    );
  }



}