import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_icons.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/icon_color_picker.dart';
import '../../../core/widgets/money_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../onboarding/data/seed_catalog.dart';
import '../data/account_repository.dart';

String accountTypeLabel(AppL10n l10n, AccountType type) => switch (type) {
      AccountType.cash => l10n.accTypeCash,
      AccountType.card => l10n.accTypeCard,
      AccountType.bank => l10n.accTypeBank,
      AccountType.savings => l10n.accTypeSavings,
      AccountType.ewallet => l10n.accTypeEwallet,
      AccountType.other => l10n.accTypeOther,
    };

class AccountEditorScreen extends ConsumerStatefulWidget {
  const AccountEditorScreen({super.key, this.editId});

  final int? editId;

  @override
  ConsumerState<AccountEditorScreen> createState() =>
      _AccountEditorScreenState();
}

class _AccountEditorScreenState extends ConsumerState<AccountEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();

  AccountType _type = AccountType.cash;
  String _currencyCode = Currency.uzs.code;
  String _iconKey = 'cash';
  int _colorValue = paletteColorAt(0);
  bool _includeInTotal = true;
  bool _iconTouched = false;
  bool _saving = false;

  Account? _existing;
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
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _currencyCode = ref.read(settingsProvider).mainCurrencyCode;

    if (!_isEditing) {
      _colorValue = paletteColorAt(DateTime.now().millisecond % 20);
      return;
    }

    final item = await ref
        .read(accountRepositoryProvider)
        .watchAccount(widget.editId!)
        .first;
    if (item == null) return;

    _existing = item.account;
    _nameController.text = item.account.name;
    _balanceController.text = Money.raw(
      item.account.initialBalance,
      currency: item.currency,
    );
    _type = item.account.type;
    _currencyCode = item.account.currency;
    _iconKey = item.account.iconKey;
    _colorValue = item.account.colorValue;
    _includeInTotal = item.account.includeInTotal;
    _iconTouched = true;
  }

  void _onTypeChanged(AccountType type) {
    setState(() {
      _type = type;
      // Foydalanuvchi ikonkani o'zi tanlamagan bo'lsa, turga mos ikonka.
      if (!_iconTouched) {
        _iconKey = AppIcons.defaultIconForAccountType(type.name);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    final repo = ref.read(accountRepositoryProvider);
    final initial = MoneyField.toMinor(_balanceController.text) ?? 0;

    try {
      if (_existing != null) {
        await repo.update(
          _existing!.copyWith(
            name: _nameController.text.trim(),
            type: _type,
            currency: _currencyCode,
            initialBalance: initial,
            iconKey: _iconKey,
            colorValue: _colorValue,
            includeInTotal: _includeInTotal,
          ),
        );
      } else {
        await repo.create(
          name: _nameController.text.trim(),
          type: _type,
          currency: _currencyCode,
          initialBalance: initial,
          iconKey: _iconKey,
          colorValue: _colorValue,
          includeInTotal: _includeInTotal,
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
        title: Text(_isEditing ? l10n.accEdit : l10n.accNew),
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
    final currency = Currency.byCode(_currencyCode);

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
                          title: l10n.accIcon,
                          selected: _iconKey,
                        );
                        if (picked != null) {
                          setState(() {
                            _iconKey = picked;
                            _iconTouched = true;
                          });
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
                        decoration: InputDecoration(
                          labelText: l10n.accName,
                          hintText: l10n.accNameHint,
                        ),
                        validator: (value) =>
                            (value ?? '').trim().isEmpty
                                ? l10n.accErrorName
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.accColor,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                ColorPickerRow(
                  selected: _colorValue,
                  onChanged: (value) => setState(() => _colorValue = value),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<AccountType>(
                  initialValue: _type,
                  decoration: InputDecoration(labelText: l10n.accType),
                  items: [
                    for (final type in AccountType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(
                              AppIcons.resolve(
                                AppIcons.defaultIconForAccountType(type.name),
                              ),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(accountTypeLabel(l10n, type)),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) _onTypeChanged(value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _currencyCode,
                  decoration: InputDecoration(labelText: l10n.accCurrency),
                  items: [
                    for (final item in Currency.all)
                      DropdownMenuItem(
                        value: item.code,
                        child: Text('${item.code}  ·  ${item.symbol}'),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _currencyCode = value);
                  },
                ),
                const SizedBox(height: 16),
                MoneyField(
                  controller: _balanceController,
                  currency: currency,
                  label: l10n.accInitialBalance,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _includeInTotal,
                  onChanged: (value) =>
                      setState(() => _includeInTotal = value),
                  title: Text(l10n.accIncludeInTotal),
                  subtitle: Text(
                    l10n.accIncludeInTotalBody,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  contentPadding: EdgeInsets.zero,
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
