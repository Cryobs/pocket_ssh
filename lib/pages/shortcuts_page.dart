import 'package:flutter/material.dart';
import 'package:pocket_ssh/models/shortcut_model.dart';
import 'package:pocket_ssh/services/shortcuts_repository.dart';
import 'package:pocket_ssh/widgets/shortcut_widget.dart';
import 'package:pocket_ssh/widgets/add_shortcut_widget.dart';
import 'package:pocket_ssh/pages/shortcut_form_page.dart';

class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({super.key});

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage>
    with AutomaticKeepAliveClientMixin {
  final _repo = ShortcutsRepository();
  List<ShortcutModel> _shortcuts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _load() async {
    await _repo.init();
    setState(() {
      _shortcuts = _repo.getAll();
    });
  }

  Future<void> _addShortcut() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShortcutFormPage()),
    );

    if (refresh == true) _load();
  }

  Future<void> _editShortcut(ShortcutModel s) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShortcutFormPage(shortcut: s),
      ),
    );

    if (refresh == true) _load();
  }

  Future<void> _removeShortcut(String id) async {
    await _repo.remove(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GridView.count(
      padding: const EdgeInsets.all(19),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        ..._shortcuts.map((s) {
          return LongPressDraggable<ShortcutModel>(
            data: s,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 175,
                height: 175,
                child: _tile(s),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.4,
              child: _tile(s),
            ),
            child: DragTarget<ShortcutModel>(
              onAccept: (dragged) {
                setState(() {
                  final from = _shortcuts.indexOf(dragged);
                  final to = _shortcuts.indexOf(s);
                  _shortcuts.removeAt(from);
                  _shortcuts.insert(to, dragged);
                });
                _repo.saveOrder(_shortcuts);
              },
              builder: (_, __, ___) => _tile(s),
            ),
          );
        }),

        AddShortcutTile(onAdd: _addShortcut),
      ],
    );
  }

  Widget _tile(ShortcutModel s) {
    return EditableShortcutTile(
      key: ValueKey(s.id),
      shortcut: s,
      onEdit: () => _editShortcut(s),
      onDelete: () => _removeShortcut(s.id),
    );
  }
}
