import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watchCategories({
    CategoryKind? kind,
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.categories)
      ..orderBy([
        (t) => OrderingTerm(expression: t.sortOrder),
        (t) => OrderingTerm(expression: t.name),
      ]);
    if (kind != null) {
      query.where((t) => t.kind.equalsValue(kind));
    }
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.watch();
  }

  Future<List<Category>> getAll() => _db.select(_db.categories).get();

  Future<int> create({
    required String name,
    required CategoryKind kind,
    required String iconKey,
    required int colorValue,
    int? parentId,
    bool isDefault = false,
  }) async {
    final maxOrder = await _db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM categories',
          readsFrom: {_db.categories},
        )
        .getSingle();

    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: name,
            kind: kind,
            iconKey: iconKey,
            colorValue: colorValue,
            parentId: Value(parentId),
            isDefault: Value(isDefault),
            sortOrder: Value(maxOrder.read<int>('m') + 1),
          ),
        );
  }

  Future<void> update(Category category) =>
      _db.update(_db.categories).replace(category);

  Future<void> setArchived(int id, {required bool archived}) {
    return (_db.update(_db.categories)..where((t) => t.id.equals(id)))
        .write(CategoriesCompanion(isArchived: Value(archived)));
  }

  /// Kategoriya o'chirilganda unga tegishli yozuvlar "Kategoriyasiz"ga
  /// o'tadi (yoki [moveTo] berilgan bo'lsa shu kategoriyaga ko'chiriladi).
  Future<void> delete(int id, {int? moveTo}) async {
    await _db.transaction(() async {
      await (_db.update(_db.transactions)
            ..where((t) => t.categoryId.equals(id)))
          .write(TransactionsCompanion(categoryId: Value(moveTo)));
      await (_db.update(_db.categories)..where((t) => t.parentId.equals(id)))
          .write(const CategoriesCompanion(parentId: Value(null)));
      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<int> transactionCount(int categoryId) async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM transactions WHERE category_id = ?1',
      variables: [Variable.withInt(categoryId)],
      readsFrom: {_db.transactions},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<void> reorder(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.categories)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(CategoriesCompanion(sortOrder: Value(i)));
      }
    });
  }

  Future<bool> hasAny() async {
    final row = await _db
        .customSelect('SELECT COUNT(*) AS c FROM categories')
        .getSingle();
    return row.read<int>('c') > 0;
  }

  /// Onboardingda standart kategoriyalarni yaratadi. Nomlar tanlangan tilda
  /// keladi — keyin foydalanuvchi ularni tahrirlashi mumkin.
  Future<void> seedDefaults(List<SeedCategory> seeds) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.categories,
        [
          for (var i = 0; i < seeds.length; i++)
            CategoriesCompanion.insert(
              name: seeds[i].name,
              kind: seeds[i].kind,
              iconKey: seeds[i].iconKey,
              colorValue: seeds[i].color,
              isDefault: const Value(true),
              sortOrder: Value(i),
            ),
        ],
      );
    });
  }
}

class SeedCategory {
  const SeedCategory({
    required this.name,
    required this.kind,
    required this.iconKey,
    required this.color,
  });

  final String name;
  final CategoryKind kind;
  final String iconKey;
  final int color;
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);

final allCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref
      .watch(categoryRepositoryProvider)
      .watchCategories(includeArchived: true),
);

final activeCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchCategories(),
);

final categoriesByKindProvider =
    StreamProvider.family<List<Category>, CategoryKind>((ref, kind) {
  return ref.watch(categoryRepositoryProvider).watchCategories(kind: kind);
});

/// `id → Category` ko'rinishidagi tez qidiruv jadvali (ro'yxatlarda ishlatiladi).
final categoryMapProvider = Provider<Map<int, Category>>((ref) {
  final list = ref.watch(allCategoriesProvider).value ?? const <Category>[];
  return {for (final c in list) c.id: c};
});
