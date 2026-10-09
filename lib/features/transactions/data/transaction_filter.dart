import 'package:flutter/foundation.dart';

import '../../../core/database/enums.dart';
import '../../../core/utils/date_range.dart';

enum TxSort { dateDesc, dateAsc, amountDesc, amountAsc }

@immutable
class TransactionFilter {
  const TransactionFilter({
    this.range,
    this.types = const {},
    this.accountIds = const {},
    this.categoryIds = const {},
    this.query = '',
    this.minAmount,
    this.maxAmount,
    this.sort = TxSort.dateDesc,
  });

  final DateRange? range;
  final Set<TransactionType> types;
  final Set<int> accountIds;
  final Set<int> categoryIds;
  final String query;
  final int? minAmount;
  final int? maxAmount;
  final TxSort sort;

  bool get isEmpty =>
      range == null &&
      types.isEmpty &&
      accountIds.isEmpty &&
      categoryIds.isEmpty &&
      query.trim().isEmpty &&
      minAmount == null &&
      maxAmount == null;

  /// Davr filtridan tashqari faol shartlar soni — UI'da badge uchun.
  int get activeCount =>
      (types.isEmpty ? 0 : 1) +
      (accountIds.isEmpty ? 0 : 1) +
      (categoryIds.isEmpty ? 0 : 1) +
      (minAmount == null && maxAmount == null ? 0 : 1) +
      (sort == TxSort.dateDesc ? 0 : 1);

  TransactionFilter copyWith({
    DateRange? range,
    bool clearRange = false,
    Set<TransactionType>? types,
    Set<int>? accountIds,
    Set<int>? categoryIds,
    String? query,
    int? minAmount,
    int? maxAmount,
    bool clearAmounts = false,
    TxSort? sort,
  }) {
    return TransactionFilter(
      range: clearRange ? null : (range ?? this.range),
      types: types ?? this.types,
      accountIds: accountIds ?? this.accountIds,
      categoryIds: categoryIds ?? this.categoryIds,
      query: query ?? this.query,
      minAmount: clearAmounts ? null : (minAmount ?? this.minAmount),
      maxAmount: clearAmounts ? null : (maxAmount ?? this.maxAmount),
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.range == range &&
      setEquals(other.types, types) &&
      setEquals(other.accountIds, accountIds) &&
      setEquals(other.categoryIds, categoryIds) &&
      other.query == query &&
      other.minAmount == minAmount &&
      other.maxAmount == maxAmount &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
        range,
        Object.hashAllUnordered(types),
        Object.hashAllUnordered(accountIds),
        Object.hashAllUnordered(categoryIds),
        query,
        minAmount,
        maxAmount,
        sort,
      );
}
