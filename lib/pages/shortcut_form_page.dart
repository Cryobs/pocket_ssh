import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pocket_ssh/models/shortcut_model.dart';
import 'package:pocket_ssh/services/shortcuts_repository.dart';
import 'package:pocket_ssh/widgets/input_big_text.dart';
import 'package:pocket_ssh/widgets/input_list.dart';
import 'package:pocket_ssh/widgets/input_text.dart';
import 'package:pocket_ssh/widgets/shortcut_widget.dart';

class ShortcutFormPage extends StatefulWidget {
  final ShortcutModel? shortcut;

  const ShortcutFormPage({super.key, this.shortcut});

  @override
  State<ShortcutFormPage> createState() => _ShortcutFormPageState();
}

class _ShortcutFormPageState extends State<ShortcutFormPage> {
  final _repo = ShortcutsRepository();

  late TextEditingController _titleController;
  late TextEditingController _hexController;

  late IconData _icon;
  late Color _color;

  Color _tempColor = Colors.blue;

  bool get isEdit => widget.shortcut != null;

  final List<IconData> _icons = [
    Icons.apps,
    Icons.security,
    Icons.language,
    Icons.folder,
    Icons.web,
    Icons.terminal,
  ];

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _titleController =
          TextEditingController(text: widget.shortcut!.title);
      _icon = widget.shortcut!.icon;
      _color = widget.shortcut!.color;
    } else {
      _titleController = TextEditingController();
      _icon = Icons.apps;
      _color = Colors.deepPurple;
    }

    _tempColor = _color;
    _hexController =
        TextEditingController(text: _color.value.toRadixString(16).substring(2));
  }

  // =========================
  // SAVE
  // =========================
  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;

    await _repo.init();

    if (isEdit) {
      widget.shortcut!
        ..title = _titleController.text
        ..iconCodePoint = _icon.codePoint
        ..colorValue = _color.value;

      await _repo.update(widget.shortcut!);
    } else {
      final existing = _repo.getAll();

      final shortcut = ShortcutModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        iconCodePoint: _icon.codePoint,
        colorValue: _color.value,
        order: existing.length,
      );


      await _repo.add(shortcut);
    }

    Navigator.pop(context, true);
  }

  // =========================
  // COLOR PICKER
  // =========================
  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Pick color', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: _tempColor,
              onColorChanged: (c) {
                setState(() {
                  _tempColor = c;
                  _hexController.text =
                      c.value.toRadixString(16).substring(2);
                });
              },
              enableAlpha: false,
              labelTypes: const [],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hexController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                prefixText: '#',
                labelText: 'HEX',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              onSubmitted: (value) {
                if (value.length == 6) {
                  final color = Color(int.parse('FF$value', radix: 16));
                  setState(() => _tempColor = color);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _color = _tempColor);
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(isEdit ? 'Edit Shortcut' : 'Add Shortcut'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: _save,
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PREVIEW
            EditableShortcutTile(
              shortcut: ShortcutModel(
                  id: "Preview_Shortcut",
                  title: _titleController.text.isEmpty
                          ? 'Preview'
                          : _titleController.text,
                  iconCodePoint: _icon.codePoint,
                  colorValue: _color.value,
                  order: 1
              ),
              onEdit: () {  },
              onDelete: () {  },
            ),

            const SizedBox(height: 24),

            // NAME
            InputText(label: "Name", hint: "My Shortcut", controller: _titleController, onChanged: (_) => setState(() {}),),
            // SERVER
            InputList(
              label: "Server",
              items: [DropdownMenuItem(value: "None", child: Text("None"))],
              value: 'None',
              onChanged: (value) {},
            ),
            const Divider(
              color: Colors.white38,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              height: 20,
            ),


            // SCRIPT
            InputBigText(label: "Script", hint: "Write a shortcut script",),


            const Divider(
              color: Colors.white38,
              thickness: 1,
              indent: 0,
              endIndent: 0,
              height: 20,
            ),
            /*
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
             */

            const SizedBox(height: 24),

            // ICON PICKER
            Wrap(
              spacing: 12,
              children: _icons.map((i) {
                return GestureDetector(
                  onTap: () => setState(() => _icon = i),
                  child: CircleAvatar(
                    backgroundColor:
                    _icon == i ? Colors.green : Colors.grey[800],
                    child: Icon(i, color: Colors.white),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // COLOR
            ElevatedButton.icon(
              onPressed: _pickColor,
              icon: const Icon(Icons.color_lens),
              label: const Text('Pick color'),
            ),
          ],
        ),
      ),
    );
  }
}
