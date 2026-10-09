import '../../../app/theme/app_colors.dart';
import '../../../core/database/enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../categories/data/category_repository.dart';

/// Standart kategoriyalar. Nomlar onboardingda tanlangan tilda yoziladi,
/// keyin foydalanuvchi ularni tahrirlashi yoki arxivlashi mumkin.
List<SeedCategory> defaultCategories(AppL10n l10n) {
  return [
    // --- Chiqim ---
    SeedCategory(
      name: l10n.seedCatFood,
      kind: CategoryKind.expense,
      iconKey: 'grocery',
      color: 0xFF2E7D32,
    ),
    SeedCategory(
      name: l10n.seedCatCafe,
      kind: CategoryKind.expense,
      iconKey: 'restaurant',
      color: 0xFFEF6C00,
    ),
    SeedCategory(
      name: l10n.seedCatTransport,
      kind: CategoryKind.expense,
      iconKey: 'transport',
      color: 0xFF0277BD,
    ),
    SeedCategory(
      name: l10n.seedCatHousing,
      kind: CategoryKind.expense,
      iconKey: 'home',
      color: 0xFF6D4C41,
    ),
    SeedCategory(
      name: l10n.seedCatUtilities,
      kind: CategoryKind.expense,
      iconKey: 'utilities',
      color: 0xFFF9A825,
    ),
    SeedCategory(
      name: l10n.seedCatInternet,
      kind: CategoryKind.expense,
      iconKey: 'internet',
      color: 0xFF00838F,
    ),
    SeedCategory(
      name: l10n.seedCatClothes,
      kind: CategoryKind.expense,
      iconKey: 'clothes',
      color: 0xFFAD1457,
    ),
    SeedCategory(
      name: l10n.seedCatHealth,
      kind: CategoryKind.expense,
      iconKey: 'health',
      color: 0xFFC2352B,
    ),
    SeedCategory(
      name: l10n.seedCatEducation,
      kind: CategoryKind.expense,
      iconKey: 'education',
      color: 0xFF3949AB,
    ),
    SeedCategory(
      name: l10n.seedCatFun,
      kind: CategoryKind.expense,
      iconKey: 'entertainment',
      color: 0xFF8E24AA,
    ),
    SeedCategory(
      name: l10n.seedCatGifts,
      kind: CategoryKind.expense,
      iconKey: 'gift',
      color: 0xFFD84315,
    ),
    SeedCategory(
      name: l10n.seedCatFamily,
      kind: CategoryKind.expense,
      iconKey: 'family',
      color: 0xFF5E35B1,
    ),
    SeedCategory(
      name: l10n.seedCatSubscription,
      kind: CategoryKind.expense,
      iconKey: 'subscription',
      color: 0xFF546E7A,
    ),
    SeedCategory(
      name: l10n.seedCatOtherExpense,
      kind: CategoryKind.expense,
      iconKey: 'other',
      color: 0xFF455A64,
    ),

    // --- Kirim ---
    SeedCategory(
      name: l10n.seedCatSalary,
      kind: CategoryKind.income,
      iconKey: 'salary',
      color: 0xFF117C4F,
    ),
    SeedCategory(
      name: l10n.seedCatScholarship,
      kind: CategoryKind.income,
      iconKey: 'scholarship',
      color: 0xFF689F38,
    ),
    SeedCategory(
      name: l10n.seedCatFreelance,
      kind: CategoryKind.income,
      iconKey: 'freelance',
      color: 0xFF00695C,
    ),
    SeedCategory(
      name: l10n.seedCatBusiness,
      kind: CategoryKind.income,
      iconKey: 'business',
      color: 0xFF1C6758,
    ),
    SeedCategory(
      name: l10n.seedCatInvestment,
      kind: CategoryKind.income,
      iconKey: 'investment',
      color: 0xFF1B5FBF,
    ),
    SeedCategory(
      name: l10n.seedCatGift,
      kind: CategoryKind.income,
      iconKey: 'gift',
      color: 0xFFAFB42B,
    ),
    SeedCategory(
      name: l10n.seedCatOtherIncome,
      kind: CategoryKind.income,
      iconKey: 'other',
      // Palitradagi oxirgi rang — "boshqa" uchun betaraf.
      color: 0xFF455A64,
    ),
  ];
}

/// Palitradan rang olish (yangi kategoriya/hisob yaratishda boshlang'ich).
int paletteColorAt(int index) =>
    AppColors.palette[index % AppColors.palette.length].toARGB32();
