// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppL10nUz extends AppL10n {
  AppL10nUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Finora';

  @override
  String get brandTagline => 'Pulingiz nazoratda';

  @override
  String get actionCancel => 'Bekor qilish';

  @override
  String get actionSave => 'Saqlash';

  @override
  String get actionDelete => 'O\'chirish';

  @override
  String get actionEdit => 'Tahrirlash';

  @override
  String get actionAdd => 'Qo\'shish';

  @override
  String get actionDone => 'Tayyor';

  @override
  String get actionNext => 'Keyingi';

  @override
  String get actionPrevious => 'Oldingi';

  @override
  String get actionSkip => 'O\'tkazib yuborish';

  @override
  String get actionClose => 'Yopish';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUndo => 'Bekor qilish';

  @override
  String get actionDuplicate => 'Nusxa ko\'chirish';

  @override
  String get actionArchive => 'Arxivlash';

  @override
  String get actionUnarchive => 'Arxivdan chiqarish';

  @override
  String get actionSearch => 'Qidirish';

  @override
  String get actionFilter => 'Filtr';

  @override
  String get actionClear => 'Tozalash';

  @override
  String get actionApply => 'Qo\'llash';

  @override
  String get actionContinue => 'Davom etish';

  @override
  String get labelAll => 'Hammasi';

  @override
  String get labelTotal => 'Jami';

  @override
  String get labelToday => 'Bugun';

  @override
  String get labelYesterday => 'Kecha';

  @override
  String get labelRequired => 'Majburiy maydon';

  @override
  String get labelOptional => 'ixtiyoriy';

  @override
  String get labelNone => 'Yo\'q';

  @override
  String get errorGeneric => 'Xatolik yuz berdi';

  @override
  String get navHome => 'Bosh';

  @override
  String get navTransactions => 'Tarix';

  @override
  String get navStats => 'Statistika';

  @override
  String get navMore => 'Yana';

  @override
  String get onbWelcomeTitle => 'Finora\'ga xush kelibsiz';

  @override
  String get onbWelcomeBody =>
      'Pulingizni nazorat qiling: qayerdan keldi, nimaga ketdi, hozir qancha qoldi.';

  @override
  String get onbPrivacyNote =>
      'Hamma ma\'lumot faqat telefoningizda saqlanadi. Internet, ro\'yxatdan o\'tish yoki server kerak emas.';

  @override
  String get onbStart => 'Boshlash';

  @override
  String onbStepOf(int step, int total) {
    return '$step-qadam / $total';
  }

  @override
  String get onbLanguageTitle => 'Tilni tanlang';

  @override
  String get onbCurrencyTitle => 'Asosiy valyuta';

  @override
  String get onbCurrencyBody => 'Umumiy balans shu valyutada ko\'rsatiladi.';

  @override
  String get onbBalanceTitle => 'Boshlang\'ich qoldiq';

  @override
  String get onbBalanceBody =>
      'Hozir qo\'lingizda va kartangizda qancha pul borligini kiriting. Keyinroq ham o\'zgartirishingiz mumkin.';

  @override
  String get onbCashQuestion => 'Qo\'lingizda qancha naqd pul bor?';

  @override
  String get onbCardQuestion => 'Kartalaringizda qancha bor?';

  @override
  String get onbAddCard => 'Karta qo\'shish';

  @override
  String get onbCardNameHint => 'Uzcard, Humo, Kapital...';

  @override
  String get onbLater => 'Keyinroq qo\'shaman';

  @override
  String get onbExtrasTitle => 'Qo\'shimcha';

  @override
  String get onbReminder => 'Kunlik eslatma';

  @override
  String get onbReminderBody =>
      'Har kuni xarajatlarni kiritishni eslatib turamiz.';

  @override
  String get onbFinish => 'Tayyor, boshlaymiz';

  @override
  String get dashTotalBalance => 'Umumiy balans';

  @override
  String get dashHideBalance => 'Balansni yashirish';

  @override
  String get dashShowBalance => 'Balansni ko\'rsatish';

  @override
  String get dashMyAccounts => 'Hisoblarim';

  @override
  String get dashThisPeriod => 'Joriy oy';

  @override
  String get dashIncome => 'Kirim';

  @override
  String get dashExpense => 'Chiqim';

  @override
  String get dashDifference => 'Farq';

  @override
  String get dashRecent => 'Oxirgi yozuvlar';

  @override
  String get dashSeeAll => 'Hammasini ko\'rish';

  @override
  String get dashEmptyTitle => 'Hali yozuv yo\'q';

  @override
  String get dashEmptyBody =>
      'Birinchi kirim yoki chiqimingizni qo\'shing — statistika o\'zi shakllanadi.';

  @override
  String get dashAddFirst => 'Birinchi yozuvni qo\'shish';

  @override
  String get txIncome => 'Kirim';

  @override
  String get txExpense => 'Chiqim';

  @override
  String get txTransfer => 'O\'tkazma';

  @override
  String get txType => 'Turi';

  @override
  String get txSortBy => 'Saralash';

  @override
  String get txNew => 'Yangi yozuv';

  @override
  String get txEdit => 'Yozuvni tahrirlash';

  @override
  String get txDetails => 'Yozuv tafsilotlari';

  @override
  String get txAmount => 'Summa';

  @override
  String get txCategory => 'Kategoriya';

  @override
  String get txAccount => 'Hisob';

  @override
  String get txFromAccount => 'Qaysi hisobdan';

  @override
  String get txToAccount => 'Qaysi hisobga';

  @override
  String get txDate => 'Sana';

  @override
  String get txTime => 'Vaqt';

  @override
  String get txNote => 'Izoh';

  @override
  String get txNoteHint => 'Nimaga sarfladingiz?';

  @override
  String get txRate => 'Kurs';

  @override
  String txRateHint(String from, String to) {
    return '1 $from = ? $to';
  }

  @override
  String txConverted(String amount) {
    return 'Tushadi: $amount';
  }

  @override
  String get txSelectCategory => 'Kategoriya tanlang';

  @override
  String get txSelectAccount => 'Hisob tanlang';

  @override
  String get txNoCategory => 'Kategoriyasiz';

  @override
  String get txErrorAmount => 'Summani kiriting';

  @override
  String get txErrorAccount => 'Hisobni tanlang';

  @override
  String get txErrorCategory => 'Kategoriyani tanlang';

  @override
  String get txErrorSameAccount => 'Bir hisobdan o\'ziga o\'tkazib bo\'lmaydi';

  @override
  String get txErrorRate => 'Kursni kiriting';

  @override
  String get txSaved => 'Saqlandi';

  @override
  String get txDeleted => 'O\'chirildi';

  @override
  String get txDeleteTitle => 'Yozuvni o\'chirasizmi?';

  @override
  String get txDeleteBody =>
      'Balans qayta hisoblanadi. Bu amalni bekor qilish mumkin.';

  @override
  String get txListTitle => 'Tarix';

  @override
  String get txEmptyTitle => 'Yozuv topilmadi';

  @override
  String get txEmptyBody =>
      'Filtrlarni o\'zgartirib ko\'ring yoki yangi yozuv qo\'shing.';

  @override
  String get txSearchHint => 'Izoh yoki kategoriya bo\'yicha qidirish';

  @override
  String get txDayTotal => 'Kun jami';

  @override
  String get txSwipeHint => 'Chapga suring — o\'chirish, o\'ngga — tahrirlash';

  @override
  String txCalcResult(String value) {
    return '= $value';
  }

  @override
  String get accTitle => 'Hisoblar';

  @override
  String get accNew => 'Yangi hisob';

  @override
  String get accEdit => 'Hisobni tahrirlash';

  @override
  String get accName => 'Nomi';

  @override
  String get accNameHint => 'Naqd, Uzcard, Humo...';

  @override
  String get accType => 'Turi';

  @override
  String get accCurrency => 'Valyuta';

  @override
  String get accInitialBalance => 'Boshlang\'ich qoldiq';

  @override
  String get accIcon => 'Ikonka';

  @override
  String get accColor => 'Rang';

  @override
  String get accIncludeInTotal => 'Umumiy balansga qo\'shilsin';

  @override
  String get accIncludeInTotalBody =>
      'O\'chirib qo\'yilsa, bu hisob umumiy summada hisobga olinmaydi.';

  @override
  String get accArchived => 'Arxivlangan';

  @override
  String get accShowArchived => 'Arxivlanganlarni ko\'rsatish';

  @override
  String get accErrorName => 'Hisob nomini kiriting';

  @override
  String get accReconcile => 'Balansni to\'g\'rilash';

  @override
  String get accReconcileBody =>
      'Haqiqiy qoldiqni kiriting — ilova farqni \"Tuzatish\" yozuvi sifatida qo\'shadi.';

  @override
  String get accRealBalance => 'Haqiqiy qoldiq';

  @override
  String get accAdjustmentNote => 'Balansni to\'g\'rilash';

  @override
  String get accReconcileNoDiff => 'Farq yo\'q — hammasi joyida';

  @override
  String accReconcileDone(String amount) {
    return 'Tuzatish yozuvi qo\'shildi: $amount';
  }

  @override
  String get accDeleteTitle => 'Hisobni o\'chirasizmi?';

  @override
  String get accDeleteBody =>
      'Hisob butunlay o\'chadi. Bu amalni bekor qilish mumkin emas.';

  @override
  String get accDeleteBlockedTitle => 'O\'chirish mumkin emas';

  @override
  String accDeleteBlockedBody(int count) {
    return 'Bu hisobda $count ta yozuv bor. Tarixni saqlab qolish uchun hisobni arxivlang.';
  }

  @override
  String get accEmptyTitle => 'Hisob yo\'q';

  @override
  String get accEmptyBody => 'Naqd pul, karta yoki bank hisobini qo\'shing.';

  @override
  String accTxCount(int count) {
    return '$count ta yozuv';
  }

  @override
  String get accReorderHint =>
      'Tartibni o\'zgartirish uchun bosib turib suring';

  @override
  String get accTypeCash => 'Naqd';

  @override
  String get accTypeCard => 'Karta';

  @override
  String get accTypeBank => 'Bank hisobi';

  @override
  String get accTypeSavings => 'Omonat';

  @override
  String get accTypeEwallet => 'Elektron hamyon';

  @override
  String get accTypeOther => 'Boshqa';

  @override
  String get catTitle => 'Kategoriyalar';

  @override
  String get catNew => 'Yangi kategoriya';

  @override
  String get catEdit => 'Kategoriyani tahrirlash';

  @override
  String get catName => 'Nomi';

  @override
  String get catKind => 'Turi';

  @override
  String get catIcon => 'Ikonka';

  @override
  String get catColor => 'Rang';

  @override
  String get catParent => 'Ota kategoriya';

  @override
  String get catNoParent => 'Asosiy kategoriya';

  @override
  String get catArchived => 'Arxivlangan';

  @override
  String get catShowArchived => 'Arxivlanganlarni ko\'rsatish';

  @override
  String get catErrorName => 'Kategoriya nomini kiriting';

  @override
  String get catDeleteTitle => 'Kategoriyani o\'chirasizmi?';

  @override
  String catDeleteBody(int count) {
    return 'Unga tegishli $count ta yozuv \"Kategoriyasiz\" holatiga o\'tadi.';
  }

  @override
  String get catEmptyTitle => 'Kategoriya yo\'q';

  @override
  String get catEmptyBody => 'Birinchi kategoriyani qo\'shing.';

  @override
  String get statTitle => 'Statistika';

  @override
  String get statTabOverview => 'Umumiy';

  @override
  String get statTabCategories => 'Kategoriyalar';

  @override
  String get statTabTrend => 'Trend';

  @override
  String get statPeriodDay => 'Kun';

  @override
  String get statPeriodWeek => 'Hafta';

  @override
  String get statPeriodMonth => 'Oy';

  @override
  String get statPeriodYear => 'Yil';

  @override
  String get statPeriodCustom => 'Oraliq';

  @override
  String get statPickRange => 'Oraliqni tanlang';

  @override
  String get statTotalIncome => 'Jami kirim';

  @override
  String get statTotalExpense => 'Jami chiqim';

  @override
  String get statNet => 'Sof natija';

  @override
  String get statAvgPerDay => 'O\'rtacha kunlik chiqim';

  @override
  String get statBiggestExpense => 'Eng katta chiqim';

  @override
  String get statTopCategory => 'Eng ko\'p ketgan kategoriya';

  @override
  String get statSavingsRate => 'Jamg\'arma foizi';

  @override
  String get statByCategory => 'Kategoriyalar bo\'yicha chiqim';

  @override
  String get statByAccount => 'Hisoblar bo\'yicha';

  @override
  String get statIncomeVsExpense => 'Kirim va chiqim';

  @override
  String get statBalanceTrend => 'Balans dinamikasi';

  @override
  String get statVsPrevious => 'oldingi davrga nisbatan';

  @override
  String get statMissingRate =>
      'Ba\'zi valyutalar uchun kurs kiritilmagan — summalar 1:1 hisoblandi.';

  @override
  String get statEmptyTitle => 'Bu davrda ma\'lumot yo\'q';

  @override
  String get statEmptyBody =>
      'Davrni o\'zgartiring yoki yangi yozuv qo\'shing.';

  @override
  String statShareOfTotal(String percent) {
    return '$percent% umumiy chiqimdan';
  }

  @override
  String get setTitle => 'Sozlamalar';

  @override
  String get setSectionGeneral => 'Umumiy';

  @override
  String get setSectionAppearance => 'Ko\'rinish';

  @override
  String get setSectionData => 'Ma\'lumot';

  @override
  String get setSectionAbout => 'Ilova haqida';

  @override
  String get setLanguage => 'Til';

  @override
  String get setTheme => 'Tema';

  @override
  String get setThemeLight => 'Yorug\'';

  @override
  String get setThemeDark => 'Qorong\'u';

  @override
  String get setThemeSystem => 'Tizim bo\'yicha';

  @override
  String get setCurrency => 'Asosiy valyuta';

  @override
  String get setMonthStartDay => 'Oyning boshlanish kuni';

  @override
  String get setMonthStartDayBody =>
      'Masalan maosh 5-sanada bo\'lsa, moliyaviy oy 5-dan boshlanadi.';

  @override
  String get setWeekStartDay => 'Haftaning boshlanish kuni';

  @override
  String get setMonday => 'Dushanba';

  @override
  String get setSunday => 'Yakshanba';

  @override
  String get setManageAccounts => 'Hisoblar';

  @override
  String get setManageCategories => 'Kategoriyalar';

  @override
  String get setBackup => 'Zaxira nusxa va eksport';

  @override
  String get setWipe => 'Barcha ma\'lumotni o\'chirish';

  @override
  String get setWipeTitle => 'Hammasini o\'chirasizmi?';

  @override
  String get setWipeBody =>
      'Barcha hisoblar, kategoriyalar va yozuvlar butunlay o\'chadi. Bu amalni bekor qilish mumkin emas.';

  @override
  String get setWipeConfirmTitle => 'Tasdiqlash';

  @override
  String setWipeConfirmBody(String word) {
    return 'Davom etish uchun quyida $word so\'zini kiriting.';
  }

  @override
  String get setWipeWord => 'O\'CHIRISH';

  @override
  String get setWipeDone => 'Barcha ma\'lumot o\'chirildi';

  @override
  String get setVersion => 'Versiya';

  @override
  String get setPrivacyTitle => 'Maxfiylik';

  @override
  String get setPrivacyBody =>
      'Finora hech qanday ma\'lumot yig\'maydi va tashqariga yubormaydi. Hamma narsa shu qurilmada qoladi.';

  @override
  String get bkpTitle => 'Zaxira nusxa';

  @override
  String get bkpSectionBackup => 'Zaxira';

  @override
  String get bkpSectionExport => 'Eksport';

  @override
  String get bkpCreate => 'Zaxira nusxa yaratish';

  @override
  String get bkpCreateBody =>
      'Barcha ma\'lumotni bitta faylga saqlaydi. Faylni Telegram, Drive yoki emailga yuborib qo\'ying.';

  @override
  String get bkpRestore => 'Fayldan tiklash';

  @override
  String get bkpRestoreBody =>
      'Telefon almashganda yoki ilovani qayta o\'rnatganda kerak bo\'ladi.';

  @override
  String get bkpExportCsv => 'CSV\'ga eksport';

  @override
  String get bkpExportCsvBody =>
      'Tanlangan davrdagi yozuvlarni jadval sifatida saqlash.';

  @override
  String bkpLast(String date) {
    return 'Oxirgi zaxira: $date';
  }

  @override
  String get bkpNever => 'Hali zaxira nusxa olinmagan';

  @override
  String bkpReminder(int days) {
    return 'Oxirgi zaxiradan $days kun o\'tdi. Nusxa olib qo\'ying.';
  }

  @override
  String get bkpCreated => 'Zaxira nusxa tayyor';

  @override
  String get bkpShareSubject => 'Finora zaxira nusxasi';

  @override
  String get bkpRestoreTitle => 'Ma\'lumotni tiklaysizmi?';

  @override
  String get bkpRestoreConfirmBody =>
      'Hozirgi barcha ma\'lumot fayldagisi bilan almashtiriladi.';

  @override
  String bkpRestored(int accounts, int transactions) {
    return 'Tiklandi: $accounts hisob, $transactions yozuv';
  }

  @override
  String get bkpInvalidFile => 'Fayl o\'qilmadi — Finora zaxira fayli emas';

  @override
  String get bkpVersionMismatch =>
      'Fayl versiyasi mos emas. Ilovani yangilang.';

  @override
  String get bkpExported => 'Fayl tayyor';

  @override
  String get seedCatFood => 'Oziq-ovqat';

  @override
  String get seedCatTransport => 'Transport';

  @override
  String get seedCatHousing => 'Uy-joy / Ijara';

  @override
  String get seedCatUtilities => 'Kommunal';

  @override
  String get seedCatInternet => 'Aloqa / Internet';

  @override
  String get seedCatClothes => 'Kiyim';

  @override
  String get seedCatHealth => 'Sog\'liq';

  @override
  String get seedCatEducation => 'Ta\'lim';

  @override
  String get seedCatFun => 'Ko\'ngilochar';

  @override
  String get seedCatCafe => 'Restoran / Kafe';

  @override
  String get seedCatGifts => 'Sovg\'alar';

  @override
  String get seedCatFamily => 'Oila';

  @override
  String get seedCatSubscription => 'Obuna';

  @override
  String get seedCatOtherExpense => 'Boshqa';

  @override
  String get seedCatSalary => 'Maosh';

  @override
  String get seedCatScholarship => 'Stipendiya';

  @override
  String get seedCatFreelance => 'Frilans';

  @override
  String get seedCatGift => 'Sovg\'a';

  @override
  String get seedCatBusiness => 'Biznes';

  @override
  String get seedCatInvestment => 'Investitsiya';

  @override
  String get seedCatOtherIncome => 'Boshqa';

  @override
  String get seedAccCash => 'Naqd';

  @override
  String get seedAccCard => 'Karta';
}
