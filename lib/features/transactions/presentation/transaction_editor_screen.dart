import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/utils/amount_expression.dart';
import '../../../core/utils/date_labels.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/design_kit.dart';
import '../../../core/widgets/money_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../accounts/data/account_repository.dart';
import '../../accounts/presentation/widgets/account_picker.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/widgets/category_picker.dart';
import '../data/transaction_repository.dart';

/// Kirim / chiqim / o'tkazma qo'shish va tahrirlash.
///
/// Maqsad — maksimum 3–4 tap: summa → kategoriya → saqlash. Qolgan maydonlar
/// (sana, izoh) oqilona standart qiymat bilan to'ldirilgan.
class TransactionEditorScreen extends ConsumerStatefulWidget {
  const TransactionEditorScreen({
    super.key,
    this.editId,
    this.initialType = TransactionType.expense,
    this.presetAccountId,
  });

  final int? editId;
  final TransactionType initialType;
  final int? presetAccountId;

  @override
  ConsumerState<TransactionEditorScreen> createState() =>
      _TransactionEditorScreenState();
}

class _TransactionEditorScreenState
    extends ConsumerState<TransactionEditorScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _rateController = TextEditingController();

  late TransactionType _type = widget.initialType;
  late Future<void> _ready;

  int? _accountId;
  int? _toAccountId;
  int? _categoryId;
  DateTime _dateTime = DateTime.now();
  bool _saving = false;
  String? _error;

  /// `true` — maketdagi raqamli klaviatura, `false` — tizim klaviaturasi
  /// (summa maydonida kalkulyator ifodasi yozish uchun).
  bool _keypad = true;

  bool get _isEditing => widget.editId != null;
  bool get _isTransfer => _type == TransactionType.transfer;

  /// Klaviatura bosilganda kursor turgan joyga belgi qo'yiladi.
  void _insert(String token) {
    final value = _amountController.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final text = value.text.replaceRange(selection.start, selection.end, token);

    setState(() {
      _amountController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(
          offset: selection.start + token.length,
        ),
      );
      _error = null;
    });
  }

  void _backspace() {
    final value = _amountController.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);

    if (selection.start == selection.end) {
      if (selection.start == 0) return;
      setState(() {
        _amountController.value = TextEditingValue(
          text: value.text.replaceRange(
            selection.start - 1,
            selection.start,
            '',
          ),
          selection: TextSelection.collapsed(offset: selection.start - 1),
        );
      });
      return;
    }

    setState(() {
      _amountController.value = TextEditingValue(
        text: value.text.replaceRange(selection.start, selection.end, ''),
        selection: TextSelection.collapsed(offset: selection.start),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _ready = _load();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final accounts = await ref
        .read(accountRepositoryProvider)
        .watchAccounts()
        .first;

    if (_isEditing) {
      final existing = await ref
          .read(transactionRepositoryProvider)
          .getById(widget.editId!);
      if (existing != null) {
        final currency = Currency.byCode(existing.account.currency);
        _type = existing.tx.type;
        _accountId = existing.tx.accountId;
        _toAccountId = existing.tx.toAccountId;
        _categoryId = existing.tx.categoryId;
        _dateTime = existing.tx.date;
        _amountController.text = Money.raw(
          existing.tx.amount,
          currency: currency,
        );
        _noteController.text = existing.tx.note ?? '';
        if (existing.tx.transferRate != null) {
          _rateController.text = existing.tx.transferRate!.toString();
        }
        return;
      }
    }

    _accountId =
        widget.presetAccountId ?? (accounts.isEmpty ? null : accounts.first.id);
    if (_isTransfer && accounts.length > 1) {
      _toAccountId = accounts[1].id;
    }
    _categoryId = await _defaultCategoryId();
  }

  Future<int?> _defaultCategoryId() async {
    if (_isTransfer) return null;
    final kind = _type == TransactionType.income
        ? CategoryKind.income
        : CategoryKind.expense;
    final categories = await ref
        .read(categoryRepositoryProvider)
        .watchCategories(kind: kind)
        .first;
    return categories.isEmpty ? null : categories.first.id;
  }

  Future<void> _changeType(TransactionType type) async {
    if (type == _type) return;
    HapticFeedback.selectionClick();
    setState(() {
      _type = type;
      _error = null;
    });
    if (_isTransfer) {
      setState(() => _categoryId = null);
      final accounts = ref.read(accountsProvider).value ?? const [];
      if (_toAccountId == null || _toAccountId == _accountId) {
        final other = accounts.where((a) => a.id != _accountId).toList();
        setState(() => _toAccountId = other.isEmpty ? null : other.first.id);
      }
    } else {
      final id = await _defaultCategoryId();
      if (mounted) setState(() => _categoryId = id);
    }
  }

  Currency _currencyOf(int? accountId) {
    final accounts =
        ref.read(accountsProvider).value ?? const <AccountWithBalance>[];
    for (final account in accounts) {
      if (account.id == accountId) return account.currency;
    }
    if (accounts.isNotEmpty) return accounts.first.currency;
    return ref.read(settingsProvider).mainCurrency;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    final l10n = AppL10n.of(context);
    final amount = MoneyField.toMinor(_amountController.text);

    String? problem;
    if (amount == null || amount <= 0) {
      problem = l10n.txErrorAmount;
    } else if (_accountId == null) {
      problem = l10n.txErrorAccount;
    } else if (_isTransfer && _toAccountId == null) {
      problem = l10n.txErrorAccount;
    } else if (_isTransfer && _toAccountId == _accountId) {
      problem = l10n.txErrorSameAccount;
    } else if (!_isTransfer && _categoryId == null) {
      problem = l10n.txErrorCategory;
    }

    double? rate;
    if (problem == null && _isTransfer) {
      final from = _currencyOf(_accountId);
      final to = _currencyOf(_toAccountId);
      if (from.code != to.code) {
        rate = double.tryParse(_rateController.text.replaceAll(',', '.'));
        if (rate == null || rate <= 0) problem = l10n.txErrorRate;
      }
    }

    if (problem != null) {
      setState(() => _error = problem);
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final draft = TxDraft(
      type: _type,
      amount: amount!,
      accountId: _accountId!,
      toAccountId: _isTransfer ? _toAccountId : null,
      categoryId: _isTransfer ? null : _categoryId,
      date: _dateTime,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      transferRate: rate,
    );

    final repo = ref.read(transactionRepositoryProvider);
    try {
      if (_isEditing) {
        await repo.updateDraft(widget.editId!, draft);
      } else {
        await repo.create(draft);
      }
      HapticFeedback.mediumImpact();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.txSaved)));
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: _isEditing ? l10n.txEdit : l10n.txNew,
              leading: RoundIconButton(
                icon: Icons.chevron_left,
                tooltip: l10n.actionCancel,
                filled: false,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _ready,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildForm(context, l10n);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, AppL10n l10n) {
    final palette = context.palette;
    final categories = ref.watch(categoryMapProvider);
    final accounts =
        ref.watch(accountsProvider).value ?? const <AccountWithBalance>[];

    final fromCurrency = _currencyOf(_accountId);
    final toCurrency = _currencyOf(_toAccountId);
    final crossCurrency = _isTransfer && fromCurrency.code != toCurrency.code;
    final typeColor = palette.forTxType(_type);

    final selectedCategory = _categoryId == null
        ? null
        : categories[_categoryId];

    AccountWithBalance? accountById(int? id) {
      for (final account in accounts) {
        if (account.id == id) return account;
      }
      return null;
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppDims.pagePadding,
              0,
              AppDims.pagePadding,
              16,
            ),
            children: [
              TypePills<TransactionType>(
                options: [
                  (TransactionType.expense, l10n.txExpense),
                  (TransactionType.income, l10n.txIncome),
                  (TransactionType.transfer, l10n.txTransfer),
                ],
                selected: _type,
                onChanged: _changeType,
                colorOf: palette.forTxType,
              ),

              // Summa: markazda, tur rangida, 48/800.
              _AmountDisplay(
                controller: _amountController,
                currency: fromCurrency,
                color: typeColor,
                readOnly: _keypad,
                keypadMode: _keypad,
                onToggleMode: () => setState(() => _keypad = !_keypad),
                onChanged: () => setState(() => _error = null),
              ),

              // Kategoriya / hisob / sana — bitta kartochkada ketma-ket.
              DesignCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (!_isTransfer)
                      ValueRow(
                        showDivider: false,
                        icon: AppIcons.resolve(
                          selectedCategory?.iconKey ?? 'category',
                        ),
                        label: l10n.txCategory,
                        value: selectedCategory?.name ?? l10n.txSelectCategory,
                        onTap: () async {
                          final picked = await showCategoryPicker(
                            context,
                            kind: _type == TransactionType.income
                                ? CategoryKind.income
                                : CategoryKind.expense,
                            selectedId: _categoryId,
                          );
                          if (picked != null) {
                            setState(() => _categoryId = picked);
                          }
                        },
                      ),
                    ValueRow(
                      showDivider: !_isTransfer,
                      icon: AppIcons.resolve(
                        accountById(_accountId)?.account.iconKey ?? 'wallet',
                      ),
                      label: _isTransfer ? l10n.txFromAccount : l10n.txAccount,
                      value:
                          accountById(_accountId)?.name ?? l10n.txSelectAccount,
                      onTap: () async {
                        final picked = await showAccountPicker(
                          context,
                          selectedId: _accountId,
                          excludeIds: _isTransfer && _toAccountId != null
                              ? {_toAccountId!}
                              : const {},
                          title: _isTransfer
                              ? l10n.txFromAccount
                              : l10n.txAccount,
                        );
                        if (picked != null) setState(() => _accountId = picked);
                      },
                    ),
                    if (_isTransfer)
                      ValueRow(
                        icon: AppIcons.resolve(
                          accountById(_toAccountId)?.account.iconKey ??
                              'wallet',
                        ),
                        label: l10n.txToAccount,
                        value:
                            accountById(_toAccountId)?.name ??
                            l10n.txSelectAccount,
                        onTap: () async {
                          final picked = await showAccountPicker(
                            context,
                            selectedId: _toAccountId,
                            excludeIds: _accountId != null
                                ? {_accountId!}
                                : const {},
                            title: l10n.txToAccount,
                          );
                          if (picked != null) {
                            setState(() => _toAccountId = picked);
                          }
                        },
                      ),
                    ValueRow(
                      icon: Icons.event_outlined,
                      label: l10n.txDate,
                      value:
                          '${DateLabels.dayHeader(context, _dateTime)}, '
                          '${DateLabels.time(context, _dateTime)}',
                      onTap: () async {
                        await _pickDate();
                        if (context.mounted) await _pickTime();
                      },
                    ),
                  ],
                ),
              ),

              if (crossCurrency) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.txRate,
                    hintText: l10n.txRateHint(
                      fromCurrency.code,
                      toCurrency.code,
                    ),
                    prefixIcon: const Icon(Icons.currency_exchange_outlined),
                  ),
                ),
                const SizedBox(height: 6),
                _ConvertedPreview(
                  amountText: _amountController.text,
                  rateText: _rateController.text,
                  toCurrency: toCurrency,
                ),
              ],

              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: '${l10n.txNote} (${l10n.labelOptional})',
                  hintText: l10n.txNoteHint,
                  prefixIcon: const Icon(Icons.notes_outlined),
                  counterText: '',
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: AppText.rowTitle.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (_keypad) ...[
                const SizedBox(height: 16),
                AmountKeypad(
                  decimalSeparator: fromCurrency.fractionDigits == 0
                      ? '000'
                      : ',',
                  backspaceTooltip: l10n.actionDelete,
                  onKey: _insert,
                  onBackspace: _backspace,
                ),
              ],
            ],
          ),
        ),
        // Asosiy harakat ekranning pastida — bir qo'l bilan ishlash uchun.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDims.pagePadding,
            8,
            AppDims.pagePadding,
            12,
          ),
          child: PrimaryAction(
            label: l10n.actionSave,
            loading: _saving,
            onPressed: _save,
          ),
        ),
      ],
    );
  }
}

/// Markazdagi katta summa (`plan/Qoshish.dc.html`): 13/700 yorliq,
/// 48/800 qiymat va valyuta belgisi 18px.
///
/// Odatda maketdagi raqamli klaviatura bilan to'ldiriladi; yorliq yonidagi
/// tugma tizim klaviaturasiga o'tkazadi — u yerda kalkulyator ifodasini
/// (`12000+5000*2`) yozish mumkin.
class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({
    required this.controller,
    required this.currency,
    required this.color,
    required this.readOnly,
    required this.keypadMode,
    required this.onToggleMode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Currency currency;
  final Color color;
  final bool readOnly;
  final bool keypadMode;
  final VoidCallback onToggleMode;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final palette = context.palette;
    final text = controller.text;
    final showResult = AmountExpression.hasOperator(text);
    final minor = MoneyField.toMinor(text);

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.txAmount,
                style: AppText.smallStrong.copyWith(color: palette.textMuted),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onToggleMode,
                tooltip: l10n.txAmount,
                visualDensity: VisualDensity.compact,
                iconSize: 18,
                icon: Icon(
                  keypadMode ? Icons.calculate_outlined : Icons.dialpad,
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // IntrinsicWidth — raqam va valyuta belgisi birga markazlashadi.
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    readOnly: readOnly,
                    showCursor: true,
                    autofocus: !readOnly,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9+\-*/().,]'),
                      ),
                    ],
                    onChanged: (_) => onChanged(),
                    style: AppText.amountHuge.copyWith(color: color),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: AppText.amountHuge.copyWith(
                        color: color.withValues(alpha: 0.35),
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                currency.symbol,
                style: AppText.sheetTitle.copyWith(color: color),
              ),
            ],
          ),
          if (showResult && minor != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.txCalcResult(Money.format(minor, currency: currency)),
                style: AppText.label.copyWith(color: palette.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConvertedPreview extends StatelessWidget {
  const _ConvertedPreview({
    required this.amountText,
    required this.rateText,
    required this.toCurrency,
  });

  final String amountText;
  final String rateText;
  final Currency toCurrency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final amount = MoneyField.toMinor(amountText);
    final rate = double.tryParse(rateText.replaceAll(',', '.'));
    if (amount == null || rate == null || rate <= 0) {
      return const SizedBox.shrink();
    }

    return Text(
      l10n.txConverted(
        Money.format(Money.convert(amount, rate), currency: toCurrency),
      ),
      style: AppText.label.copyWith(color: context.palette.primary),
    );
  }
}
