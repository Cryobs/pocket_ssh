import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class PrivateKey {
  final String id;
  final String name;
  final String key;

  PrivateKey({
    required this.id,
    required this.name,
    required this.key,
  });
}

class PrivateKeyList extends StatefulWidget {
  const PrivateKeyList({super.key});

  @override
  State<StatefulWidget> createState() => _PrivateKeyListState();
}

class _PrivateKeyListState extends State<PrivateKeyList>{
  List<PrivateKey> keys = [];

  @override
  void initState() {
    super.initState();

    keys = [
      PrivateKey(id: "0", name: "Server", key: "some key"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.bottomLeft,
          child: Text("Private Keys", style: TextStyle(color: Colors.white, fontSize: 16),),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index == keys.length) {
              return GestureDetector(
                onTap: () {}, // Navigate to Add Key Page
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: const Center(
                    child: Icon(Icons.add_circle_outline, color: Colors.white38),
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () {},  // Navigate to Edit Key Page
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black38,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, color: Colors.white, size: 20),
                    const SizedBox(width: 12,),
                    Expanded(
                        child: Text(
                          keys[index].name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16
                          )
                        )
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemCount: keys.length + 1,
        )
      ],
    );
  }

}
