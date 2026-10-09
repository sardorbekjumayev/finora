import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../onboarding/data/seed_catalog.dart';
import '../data/category_repository.dart';

String categoryKindLabel(AppL10n l10n, CategoryKind kind) => switch (kind) {
      CategoryKind.income => l10n.txIncome,
      CategoryKind.expense => l10n.txExpense,
    };

class CategoryEditorScreen extends ConsumerStatefulWidget {
  const CategoryEditorScreen({
    super.key,
    this.editId,
    this.initialKind = CategoryKind.expense,
  });

  final int? editId;
  final CategoryKind initialKind;

  @override
  ConsumerState<CategoryEditorScreen> createState() =>
      _CategoryEditorScreenState();
}

class _CategoryEditorScreenState extends ConsumerState<CategoryEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  late CategoryKind _kind = widget.initialKind;
  String _iconKey = 'category';
  int _colorValue = paletteColorAt(0);
  int? _parentId;
  bool _saving = false;

  Category? _existing;
  late Future<void> _ready;

  bool get _isEditing => widget.editId != null;

  @override
  void initState() {
    super.initState();
    _ready = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!_isEditing) {
      _colorValue = paletteColorAt(DateTime.now().millisecond);
      return;
    }

    final all = await ref.read(categoryRepositoryProvider).getAll();
    final item = all.where((c) => c.id == widget.editId).firstOrNull;
    if (item == null) return;

    _existing = item;
    _nameController.text = item.name;
    _kind = item.kind;
    _iconKey = item.iconKey;
    _colorValue = item.colorValue;
    _parentId = item.parentId;
  }

  /// Ota bo'la oladigan kategoriyalar: faqat shu turdagi, o'zidan tashqari
  /// va o'zining bolasi bo'lmaganlar (ikki pog'onadan chuqur ketmaydi).
  List<Category> _parentCandidates(List<Category> all) {
    return all
        .where(
          (c) =>
              c.kind == _kind &&
              !c.isArchived &&
              c.id != _existing?.id &&
              c.parentId == null &&
              c.parentId != _existing?.id,
        )
        .toList(growable: false);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final repo = ref.read(categoryRepositoryProvider);

    try {
      if (_existing != null) {
        await repo.update(
          _existing!.copyWith(
            name: _nameController.text.trim(),
            kind: _kind,
            iconKey: _iconKey,
            colorValue: _colorValue,
            parentId: Value(_parentId),
          ),
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          kind: _kind,
          iconKey: _iconKey,
          colorValue: _colorValue,
          parentId: _parentId,
        );
      }
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.catEdit : l10n.catNew),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: l10n.actionCancel,
        ),
      ),
      body: FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildForm(context, l10n);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppL10n l10n) {
    final all = ref.watch(allCategoriesProvider).value ?? const <Category>[];
    final parents = _parentCandidates(all);
    // Tur o'zgarsa eski ota kategoriya endi mos kelmasligi mumkin.
    final parentValue =
        parents.any((c) => c.id == _parentId) ? _parentId : null;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await showIconPicker(
                          context,
                          title: l10n.catIcon,
                          selected: _iconKey,
                        );
                        if (picked != null) {
                          setState(() => _iconKey = picked);
                        }
                      },
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          IconBadge(
                            iconKey: _iconKey,
                            colorValue: _colorValue,
                            size: 60,
                          ),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: l10n.catName),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? l10n.catErrorName
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.catKind, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<CategoryKind>(
                  segments: [
                    for (final kind in CategoryKind.values)
                      ButtonSegment(
                        value: kind,
                        label: Text(categoryKindLabel(l10n, kind)),
                      ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (selection) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _kind = selection.first;
                      _parentId = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.catColor,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                ColorPickerRow(
                  selected: _colorValue,
                  onChanged: (value) => setState(() => _colorValue = value),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<int?>(
                  initialValue: parentValue,
                  decoration: InputDecoration(labelText: l10n.catParent),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.catNoParent)),
                    for (final parent in parents)
                      DropdownMenuItem(
                        value: parent.id,
                        child: Row(
                          children: [
                            IconBadge(
                              iconKey: parent.iconKey,
                              colorValue: parent.colorValue,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(parent.name),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _parentId = value),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.actionSave),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
