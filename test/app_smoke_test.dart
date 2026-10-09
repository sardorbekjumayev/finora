import 'package:drift/native.dart';
import 'package:finora/app/app.dart';
import 'package:finora/core/database/app_database.dart';
import 'package:finora/core/providers/database_provider.dart';
import 'package:finora/core/services/settings_service.dart';
import 'package:finora/features/accounts/data/account_repository.dart';
import 'package:finora/features/categories/data/category_repository.dart';
import 'package:finora/features/transactions/data/transaction_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Butun ilovani in-memory baza bilan ko'taradi — ekranlar va grafiklar
/// haqiqatan qurilishini tekshiradi. Onboarding o'tkazilgan holatdan
/// boshlanadi, shuning uchun darhol bosh sahifa chiqadi.
///
/// `pumpAndSettle` ishlatilmaydi: drift stream'lari haqiqiy async'da
/// ishlaydi, `CircularProgressIndicator` esa cheksiz aylanadi — ikkisi
/// birga `pumpAndSettle`ni hech qachon tugatmaydi. Shu sababli har pump
/// `runAsync` bilan birga bajariladi ([settle]ga qarang).
void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  // Maketdagi pastki navigatsiya ikonkalari (`lib/app/home_shell.dart`).
  const navTransactions = Icons.format_list_bulleted;
  const navStats = Icons.bar_chart_outlined;
  const navMore = Icons.grid_view_outlined;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({
      'onboarding_done': true,
      'locale_code': 'uz',
      'main_currency': 'UZS',
    });
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() => db.close());

  /// Haqiqiy async ishini (baza so'rovlari) va kadr chizishni navbat bilan
  /// aylantiradi — stream'lar ulgurib, animatsiyalar ham tugaydi.
  Future<void> settle(WidgetTester tester, {int rounds = 6}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const FinoraApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  Future<void> seed() async {
    final cash = await AccountRepository(db).create(
      name: 'Naqd',
      type: AccountType.cash,
      currency: 'UZS',
      initialBalance: 50000000,
      iconKey: 'cash',
      colorValue: 0xFF1C6758,
    );
    final food = await CategoryRepository(db).create(
      name: 'Oziq-ovqat',
      kind: CategoryKind.expense,
      iconKey: 'grocery',
      colorValue: 0xFF2E7D32,
    );
    await TransactionRepository(db).create(
      TxDraft(
        type: TransactionType.expense,
        amount: 4500000,
        accountId: cash,
        categoryId: food,
        date: DateTime.now(),
      ),
    );
  }

  testWidgets('bo\'sh bazada bosh sahifa bo\'sh holatni ko\'rsatadi',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Finora'), findsOneWidget);
    expect(find.text('Hali yozuv yo\'q'), findsWidgets);
  });

  testWidgets('yozuv bo\'lsa bosh sahifada balans ko\'rinadi', (tester) async {
    await seed();
    await pumpApp(tester);

    expect(find.text('Umumiy balans'), findsOneWidget);
    expect(find.text('Naqd'), findsWidgets);
    expect(find.text('Oziq-ovqat'), findsWidgets);
  });

  testWidgets('balansni yashirish summalarni berkitadi', (tester) async {
    await seed();
    await pumpApp(tester);

    expect(find.text('••••••'), findsNothing);
    await tapAndSettle(tester, find.byTooltip('Balansni yashirish'));
    expect(find.text('••••••'), findsWidgets);
  });

  testWidgets('pastdagi to\'rt bo\'lim ham ochiladi', (tester) async {
    await seed();
    await pumpApp(tester);

    await tapAndSettle(tester, find.byIcon(navTransactions));
    expect(find.text('Tarix'), findsWidgets);

    await tapAndSettle(tester, find.byIcon(navStats));
    expect(find.text('Statistika'), findsWidgets);
    expect(find.text('Jami chiqim'), findsOneWidget);

    await tapAndSettle(tester, find.byIcon(navMore));
    expect(find.text('Yana'), findsWidgets);
    expect(find.text('Hisoblar'), findsWidgets);
  });

  testWidgets('statistika bitta oqimda donut va grafiklarni quradi',
      (tester) async {
    await seed();
    await pumpApp(tester);
    await tapAndSettle(tester, find.byIcon(navStats));

    expect(find.text('Kategoriyalar bo\'yicha chiqim'), findsOneWidget);
    expect(find.text('Oziq-ovqat'), findsWidgets);
    expect(find.text('Kirim va chiqim'), findsOneWidget);
    expect(find.text('Balans dinamikasi'), findsOneWidget);
  });

  testWidgets('davrni oldinga/orqaga surish ishlaydi', (tester) async {
    await seed();
    await pumpApp(tester);
    await tapAndSettle(tester, find.byIcon(navStats));

    await tapAndSettle(tester, find.text('Hafta'));
    await tapAndSettle(tester, find.byTooltip('Oldingi'));
    // O'tgan haftada yozuv yo'q — bo'sh holat chiqadi.
    expect(find.text('Bu davrda ma\'lumot yo\'q'), findsWidgets);
  });

  testWidgets('sozlamalar ochiladi va tema saqlanadi', (tester) async {
    await pumpApp(tester);
    await tapAndSettle(tester, find.byTooltip('Sozlamalar'));

    expect(find.text('Til'), findsOneWidget);
    expect(find.text('Tema'), findsOneWidget);

    await tapAndSettle(tester, find.text('Qorong\'u'));
    expect(prefs.getString('theme_mode'), 'dark');
  });

  testWidgets('zaxira ekrani ochiladi', (tester) async {
    await pumpApp(tester);

    await tapAndSettle(tester, find.byIcon(navMore));
    await tapAndSettle(tester, find.text('Zaxira nusxa va eksport'));

    expect(find.text('Zaxira nusxa yaratish'), findsOneWidget);
    expect(find.text('Fayldan tiklash'), findsOneWidget);
    expect(find.text('CSV\'ga eksport'), findsOneWidget);
  });

  testWidgets('kategoriya tahrirlash formasi ochiladi', (tester) async {
    await seed();
    await pumpApp(tester);

    await tapAndSettle(tester, find.byIcon(navMore));
    await tapAndSettle(tester, find.text('Kategoriyalar').last);
    await tapAndSettle(tester, find.text('Oziq-ovqat'));

    expect(find.text('Kategoriyani tahrirlash'), findsOneWidget);
    expect(find.text('Asosiy kategoriya'), findsWidgets);
  });

  testWidgets('yangi yozuv formasi markazdagi tugma orqali ochiladi',
      (tester) async {
    await seed();
    await pumpApp(tester);

    await tapAndSettle(tester, find.byTooltip('Yangi yozuv'));
    expect(find.text('Yangi yozuv'), findsWidgets);
    // Maketdagi raqamli klaviatura — summa shu tugmalar bilan kiritiladi.
    expect(find.text('7'), findsOneWidget);
  });
}
