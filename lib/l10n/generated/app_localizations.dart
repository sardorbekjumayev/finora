import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'Finora'**
  String get appTitle;

  /// No description provided for @brandTagline.
  ///
  /// In uz, this message translates to:
  /// **'Pulingiz nazoratda'**
  String get brandTagline;

  /// No description provided for @actionCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shish'**
  String get actionAdd;

  /// No description provided for @actionDone.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor'**
  String get actionDone;

  /// No description provided for @actionNext.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi'**
  String get actionNext;

  /// No description provided for @actionPrevious.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi'**
  String get actionPrevious;

  /// No description provided for @actionSkip.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazib yuborish'**
  String get actionSkip;

  /// No description provided for @actionClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get actionClose;

  /// No description provided for @actionOk.
  ///
  /// In uz, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @actionUndo.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get actionUndo;

  /// No description provided for @actionDuplicate.
  ///
  /// In uz, this message translates to:
  /// **'Nusxa ko\'chirish'**
  String get actionDuplicate;

  /// No description provided for @actionArchive.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlash'**
  String get actionArchive;

  /// No description provided for @actionUnarchive.
  ///
  /// In uz, this message translates to:
  /// **'Arxivdan chiqarish'**
  String get actionUnarchive;

  /// No description provided for @actionSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get actionSearch;

  /// No description provided for @actionFilter.
  ///
  /// In uz, this message translates to:
  /// **'Filtr'**
  String get actionFilter;

  /// No description provided for @actionClear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get actionClear;

  /// No description provided for @actionApply.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llash'**
  String get actionApply;

  /// No description provided for @actionContinue.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get actionContinue;

  /// No description provided for @labelAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get labelAll;

  /// No description provided for @labelTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get labelTotal;

  /// No description provided for @labelToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get labelToday;

  /// No description provided for @labelYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get labelYesterday;

  /// No description provided for @labelRequired.
  ///
  /// In uz, this message translates to:
  /// **'Majburiy maydon'**
  String get labelRequired;

  /// No description provided for @labelOptional.
  ///
  /// In uz, this message translates to:
  /// **'ixtiyoriy'**
  String get labelOptional;

  /// No description provided for @labelNone.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get labelNone;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get errorGeneric;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh'**
  String get navHome;

  /// No description provided for @navTransactions.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get navTransactions;

  /// No description provided for @navStats.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get navStats;

  /// No description provided for @navMore.
  ///
  /// In uz, this message translates to:
  /// **'Yana'**
  String get navMore;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Finora\'ga xush kelibsiz'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In uz, this message translates to:
  /// **'Pulingizni nazorat qiling: qayerdan keldi, nimaga ketdi, hozir qancha qoldi.'**
  String get onbWelcomeBody;

  /// No description provided for @onbPrivacyNote.
  ///
  /// In uz, this message translates to:
  /// **'Hamma ma\'lumot faqat telefoningizda saqlanadi. Internet, ro\'yxatdan o\'tish yoki server kerak emas.'**
  String get onbPrivacyNote;

  /// No description provided for @onbStart.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get onbStart;

  /// No description provided for @onbStepOf.
  ///
  /// In uz, this message translates to:
  /// **'{step}-qadam / {total}'**
  String onbStepOf(int step, int total);

  /// No description provided for @onbLanguageTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get onbLanguageTitle;

  /// No description provided for @onbCurrencyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy valyuta'**
  String get onbCurrencyTitle;

  /// No description provided for @onbCurrencyBody.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy balans shu valyutada ko\'rsatiladi.'**
  String get onbCurrencyBody;

  /// No description provided for @onbBalanceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang\'ich qoldiq'**
  String get onbBalanceTitle;

  /// No description provided for @onbBalanceBody.
  ///
  /// In uz, this message translates to:
  /// **'Hozir qo\'lingizda va kartangizda qancha pul borligini kiriting. Keyinroq ham o\'zgartirishingiz mumkin.'**
  String get onbBalanceBody;

  /// No description provided for @onbCashQuestion.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'lingizda qancha naqd pul bor?'**
  String get onbCashQuestion;

  /// No description provided for @onbCardQuestion.
  ///
  /// In uz, this message translates to:
  /// **'Kartalaringizda qancha bor?'**
  String get onbCardQuestion;

  /// No description provided for @onbAddCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta qo\'shish'**
  String get onbAddCard;

  /// No description provided for @onbCardNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Uzcard, Humo, Kapital...'**
  String get onbCardNameHint;

  /// No description provided for @onbLater.
  ///
  /// In uz, this message translates to:
  /// **'Keyinroq qo\'shaman'**
  String get onbLater;

  /// No description provided for @onbExtrasTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'shimcha'**
  String get onbExtrasTitle;

  /// No description provided for @onbReminder.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik eslatma'**
  String get onbReminder;

  /// No description provided for @onbReminderBody.
  ///
  /// In uz, this message translates to:
  /// **'Har kuni xarajatlarni kiritishni eslatib turamiz.'**
  String get onbReminderBody;

  /// No description provided for @onbFinish.
  ///
  /// In uz, this message translates to:
  /// **'Tayyor, boshlaymiz'**
  String get onbFinish;

  /// No description provided for @dashTotalBalance.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy balans'**
  String get dashTotalBalance;

  /// No description provided for @dashHideBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansni yashirish'**
  String get dashHideBalance;

  /// No description provided for @dashShowBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansni ko\'rsatish'**
  String get dashShowBalance;

  /// No description provided for @dashMyAccounts.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblarim'**
  String get dashMyAccounts;

  /// No description provided for @dashThisPeriod.
  ///
  /// In uz, this message translates to:
  /// **'Joriy oy'**
  String get dashThisPeriod;

  /// No description provided for @dashIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get dashIncome;

  /// No description provided for @dashExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get dashExpense;

  /// No description provided for @dashDifference.
  ///
  /// In uz, this message translates to:
  /// **'Farq'**
  String get dashDifference;

  /// No description provided for @dashRecent.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi yozuvlar'**
  String get dashRecent;

  /// No description provided for @dashSeeAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini ko\'rish'**
  String get dashSeeAll;

  /// No description provided for @dashEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hali yozuv yo\'q'**
  String get dashEmptyTitle;

  /// No description provided for @dashEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi kirim yoki chiqimingizni qo\'shing — statistika o\'zi shakllanadi.'**
  String get dashEmptyBody;

  /// No description provided for @dashAddFirst.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi yozuvni qo\'shish'**
  String get dashAddFirst;

  /// No description provided for @txIncome.
  ///
  /// In uz, this message translates to:
  /// **'Kirim'**
  String get txIncome;

  /// No description provided for @txExpense.
  ///
  /// In uz, this message translates to:
  /// **'Chiqim'**
  String get txExpense;

  /// No description provided for @txTransfer.
  ///
  /// In uz, this message translates to:
  /// **'O\'tkazma'**
  String get txTransfer;

  /// No description provided for @txType.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get txType;

  /// No description provided for @txSortBy.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get txSortBy;

  /// No description provided for @txNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi yozuv'**
  String get txNew;

  /// No description provided for @txEdit.
  ///
  /// In uz, this message translates to:
  /// **'Yozuvni tahrirlash'**
  String get txEdit;

  /// No description provided for @txDetails.
  ///
  /// In uz, this message translates to:
  /// **'Yozuv tafsilotlari'**
  String get txDetails;

  /// No description provided for @txAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summa'**
  String get txAmount;

  /// No description provided for @txCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya'**
  String get txCategory;

  /// No description provided for @txAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisob'**
  String get txAccount;

  /// No description provided for @txFromAccount.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hisobdan'**
  String get txFromAccount;

  /// No description provided for @txToAccount.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hisobga'**
  String get txToAccount;

  /// No description provided for @txDate.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get txDate;

  /// No description provided for @txTime.
  ///
  /// In uz, this message translates to:
  /// **'Vaqt'**
  String get txTime;

  /// No description provided for @txNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get txNote;

  /// No description provided for @txNoteHint.
  ///
  /// In uz, this message translates to:
  /// **'Nimaga sarfladingiz?'**
  String get txNoteHint;

  /// No description provided for @txRate.
  ///
  /// In uz, this message translates to:
  /// **'Kurs'**
  String get txRate;

  /// No description provided for @txRateHint.
  ///
  /// In uz, this message translates to:
  /// **'1 {from} = ? {to}'**
  String txRateHint(String from, String to);

  /// No description provided for @txConverted.
  ///
  /// In uz, this message translates to:
  /// **'Tushadi: {amount}'**
  String txConverted(String amount);

  /// No description provided for @txSelectCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya tanlang'**
  String get txSelectCategory;

  /// No description provided for @txSelectAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisob tanlang'**
  String get txSelectAccount;

  /// No description provided for @txNoCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyasiz'**
  String get txNoCategory;

  /// No description provided for @txErrorAmount.
  ///
  /// In uz, this message translates to:
  /// **'Summani kiriting'**
  String get txErrorAmount;

  /// No description provided for @txErrorAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni tanlang'**
  String get txErrorAccount;

  /// No description provided for @txErrorCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tanlang'**
  String get txErrorCategory;

  /// No description provided for @txErrorSameAccount.
  ///
  /// In uz, this message translates to:
  /// **'Bir hisobdan o\'ziga o\'tkazib bo\'lmaydi'**
  String get txErrorSameAccount;

  /// No description provided for @txErrorRate.
  ///
  /// In uz, this message translates to:
  /// **'Kursni kiriting'**
  String get txErrorRate;

  /// No description provided for @txSaved.
  ///
  /// In uz, this message translates to:
  /// **'Saqlandi'**
  String get txSaved;

  /// No description provided for @txDeleted.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirildi'**
  String get txDeleted;

  /// No description provided for @txDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yozuvni o\'chirasizmi?'**
  String get txDeleteTitle;

  /// No description provided for @txDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Balans qayta hisoblanadi. Bu amalni bekor qilish mumkin.'**
  String get txDeleteBody;

  /// No description provided for @txListTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tarix'**
  String get txListTitle;

  /// No description provided for @txEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yozuv topilmadi'**
  String get txEmptyTitle;

  /// No description provided for @txEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlarni o\'zgartirib ko\'ring yoki yangi yozuv qo\'shing.'**
  String get txEmptyBody;

  /// No description provided for @txSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Izoh yoki kategoriya bo\'yicha qidirish'**
  String get txSearchHint;

  /// No description provided for @txDayTotal.
  ///
  /// In uz, this message translates to:
  /// **'Kun jami'**
  String get txDayTotal;

  /// No description provided for @txSwipeHint.
  ///
  /// In uz, this message translates to:
  /// **'Chapga suring — o\'chirish, o\'ngga — tahrirlash'**
  String get txSwipeHint;

  /// No description provided for @txCalcResult.
  ///
  /// In uz, this message translates to:
  /// **'= {value}'**
  String txCalcResult(String value);

  /// No description provided for @accTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar'**
  String get accTitle;

  /// No description provided for @accNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi hisob'**
  String get accNew;

  /// No description provided for @accEdit.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni tahrirlash'**
  String get accEdit;

  /// No description provided for @accName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get accName;

  /// No description provided for @accNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Naqd, Uzcard, Humo...'**
  String get accNameHint;

  /// No description provided for @accType.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get accType;

  /// No description provided for @accCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Valyuta'**
  String get accCurrency;

  /// No description provided for @accInitialBalance.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang\'ich qoldiq'**
  String get accInitialBalance;

  /// No description provided for @accIcon.
  ///
  /// In uz, this message translates to:
  /// **'Ikonka'**
  String get accIcon;

  /// No description provided for @accColor.
  ///
  /// In uz, this message translates to:
  /// **'Rang'**
  String get accColor;

  /// No description provided for @accIncludeInTotal.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy balansga qo\'shilsin'**
  String get accIncludeInTotal;

  /// No description provided for @accIncludeInTotalBody.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirib qo\'yilsa, bu hisob umumiy summada hisobga olinmaydi.'**
  String get accIncludeInTotalBody;

  /// No description provided for @accArchived.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlangan'**
  String get accArchived;

  /// No description provided for @accShowArchived.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlanganlarni ko\'rsatish'**
  String get accShowArchived;

  /// No description provided for @accErrorName.
  ///
  /// In uz, this message translates to:
  /// **'Hisob nomini kiriting'**
  String get accErrorName;

  /// No description provided for @accReconcile.
  ///
  /// In uz, this message translates to:
  /// **'Balansni to\'g\'rilash'**
  String get accReconcile;

  /// No description provided for @accReconcileBody.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqiy qoldiqni kiriting — ilova farqni \"Tuzatish\" yozuvi sifatida qo\'shadi.'**
  String get accReconcileBody;

  /// No description provided for @accRealBalance.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqiy qoldiq'**
  String get accRealBalance;

  /// No description provided for @accAdjustmentNote.
  ///
  /// In uz, this message translates to:
  /// **'Balansni to\'g\'rilash'**
  String get accAdjustmentNote;

  /// No description provided for @accReconcileNoDiff.
  ///
  /// In uz, this message translates to:
  /// **'Farq yo\'q — hammasi joyida'**
  String get accReconcileNoDiff;

  /// No description provided for @accReconcileDone.
  ///
  /// In uz, this message translates to:
  /// **'Tuzatish yozuvi qo\'shildi: {amount}'**
  String accReconcileDone(String amount);

  /// No description provided for @accDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirasizmi?'**
  String get accDeleteTitle;

  /// No description provided for @accDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisob butunlay o\'chadi. Bu amalni bekor qilish mumkin emas.'**
  String get accDeleteBody;

  /// No description provided for @accDeleteBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish mumkin emas'**
  String get accDeleteBlockedTitle;

  /// No description provided for @accDeleteBlockedBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu hisobda {count} ta yozuv bor. Tarixni saqlab qolish uchun hisobni arxivlang.'**
  String accDeleteBlockedBody(int count);

  /// No description provided for @accEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob yo\'q'**
  String get accEmptyTitle;

  /// No description provided for @accEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Naqd pul, karta yoki bank hisobini qo\'shing.'**
  String get accEmptyBody;

  /// No description provided for @accTxCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta yozuv'**
  String accTxCount(int count);

  /// No description provided for @accReorderHint.
  ///
  /// In uz, this message translates to:
  /// **'Tartibni o\'zgartirish uchun bosib turib suring'**
  String get accReorderHint;

  /// No description provided for @accTypeCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get accTypeCash;

  /// No description provided for @accTypeCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get accTypeCard;

  /// No description provided for @accTypeBank.
  ///
  /// In uz, this message translates to:
  /// **'Bank hisobi'**
  String get accTypeBank;

  /// No description provided for @accTypeSavings.
  ///
  /// In uz, this message translates to:
  /// **'Omonat'**
  String get accTypeSavings;

  /// No description provided for @accTypeEwallet.
  ///
  /// In uz, this message translates to:
  /// **'Elektron hamyon'**
  String get accTypeEwallet;

  /// No description provided for @accTypeOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get accTypeOther;

  /// No description provided for @catTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get catTitle;

  /// No description provided for @catNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kategoriya'**
  String get catNew;

  /// No description provided for @catEdit.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani tahrirlash'**
  String get catEdit;

  /// No description provided for @catName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get catName;

  /// No description provided for @catKind.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get catKind;

  /// No description provided for @catIcon.
  ///
  /// In uz, this message translates to:
  /// **'Ikonka'**
  String get catIcon;

  /// No description provided for @catColor.
  ///
  /// In uz, this message translates to:
  /// **'Rang'**
  String get catColor;

  /// No description provided for @catParent.
  ///
  /// In uz, this message translates to:
  /// **'Ota kategoriya'**
  String get catParent;

  /// No description provided for @catNoParent.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy kategoriya'**
  String get catNoParent;

  /// No description provided for @catArchived.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlangan'**
  String get catArchived;

  /// No description provided for @catShowArchived.
  ///
  /// In uz, this message translates to:
  /// **'Arxivlanganlarni ko\'rsatish'**
  String get catShowArchived;

  /// No description provided for @catErrorName.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya nomini kiriting'**
  String get catErrorName;

  /// No description provided for @catDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyani o\'chirasizmi?'**
  String get catDeleteTitle;

  /// No description provided for @catDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Unga tegishli {count} ta yozuv \"Kategoriyasiz\" holatiga o\'tadi.'**
  String catDeleteBody(int count);

  /// No description provided for @catEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriya yo\'q'**
  String get catEmptyTitle;

  /// No description provided for @catEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Birinchi kategoriyani qo\'shing.'**
  String get catEmptyBody;

  /// No description provided for @statTitle.
  ///
  /// In uz, this message translates to:
  /// **'Statistika'**
  String get statTitle;

  /// No description provided for @statTabOverview.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy'**
  String get statTabOverview;

  /// No description provided for @statTabCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get statTabCategories;

  /// No description provided for @statTabTrend.
  ///
  /// In uz, this message translates to:
  /// **'Trend'**
  String get statTabTrend;

  /// No description provided for @statPeriodDay.
  ///
  /// In uz, this message translates to:
  /// **'Kun'**
  String get statPeriodDay;

  /// No description provided for @statPeriodWeek.
  ///
  /// In uz, this message translates to:
  /// **'Hafta'**
  String get statPeriodWeek;

  /// No description provided for @statPeriodMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oy'**
  String get statPeriodMonth;

  /// No description provided for @statPeriodYear.
  ///
  /// In uz, this message translates to:
  /// **'Yil'**
  String get statPeriodYear;

  /// No description provided for @statPeriodCustom.
  ///
  /// In uz, this message translates to:
  /// **'Oraliq'**
  String get statPeriodCustom;

  /// No description provided for @statPickRange.
  ///
  /// In uz, this message translates to:
  /// **'Oraliqni tanlang'**
  String get statPickRange;

  /// No description provided for @statTotalIncome.
  ///
  /// In uz, this message translates to:
  /// **'Jami kirim'**
  String get statTotalIncome;

  /// No description provided for @statTotalExpense.
  ///
  /// In uz, this message translates to:
  /// **'Jami chiqim'**
  String get statTotalExpense;

  /// No description provided for @statNet.
  ///
  /// In uz, this message translates to:
  /// **'Sof natija'**
  String get statNet;

  /// No description provided for @statAvgPerDay.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha kunlik chiqim'**
  String get statAvgPerDay;

  /// No description provided for @statBiggestExpense.
  ///
  /// In uz, this message translates to:
  /// **'Eng katta chiqim'**
  String get statBiggestExpense;

  /// No description provided for @statTopCategory.
  ///
  /// In uz, this message translates to:
  /// **'Eng ko\'p ketgan kategoriya'**
  String get statTopCategory;

  /// No description provided for @statSavingsRate.
  ///
  /// In uz, this message translates to:
  /// **'Jamg\'arma foizi'**
  String get statSavingsRate;

  /// No description provided for @statByCategory.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar bo\'yicha chiqim'**
  String get statByCategory;

  /// No description provided for @statByAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar bo\'yicha'**
  String get statByAccount;

  /// No description provided for @statIncomeVsExpense.
  ///
  /// In uz, this message translates to:
  /// **'Kirim va chiqim'**
  String get statIncomeVsExpense;

  /// No description provided for @statBalanceTrend.
  ///
  /// In uz, this message translates to:
  /// **'Balans dinamikasi'**
  String get statBalanceTrend;

  /// No description provided for @statVsPrevious.
  ///
  /// In uz, this message translates to:
  /// **'oldingi davrga nisbatan'**
  String get statVsPrevious;

  /// No description provided for @statMissingRate.
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi valyutalar uchun kurs kiritilmagan — summalar 1:1 hisoblandi.'**
  String get statMissingRate;

  /// No description provided for @statEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu davrda ma\'lumot yo\'q'**
  String get statEmptyTitle;

  /// No description provided for @statEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Davrni o\'zgartiring yoki yangi yozuv qo\'shing.'**
  String get statEmptyBody;

  /// No description provided for @statShareOfTotal.
  ///
  /// In uz, this message translates to:
  /// **'{percent}% umumiy chiqimdan'**
  String statShareOfTotal(String percent);

  /// No description provided for @setTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get setTitle;

  /// No description provided for @setSectionGeneral.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy'**
  String get setSectionGeneral;

  /// No description provided for @setSectionAppearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get setSectionAppearance;

  /// No description provided for @setSectionData.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot'**
  String get setSectionData;

  /// No description provided for @setSectionAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get setSectionAbout;

  /// No description provided for @setLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get setLanguage;

  /// No description provided for @setTheme.
  ///
  /// In uz, this message translates to:
  /// **'Tema'**
  String get setTheme;

  /// No description provided for @setThemeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get setThemeLight;

  /// No description provided for @setThemeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'u'**
  String get setThemeDark;

  /// No description provided for @setThemeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim bo\'yicha'**
  String get setThemeSystem;

  /// No description provided for @setCurrency.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy valyuta'**
  String get setCurrency;

  /// No description provided for @setMonthStartDay.
  ///
  /// In uz, this message translates to:
  /// **'Oyning boshlanish kuni'**
  String get setMonthStartDay;

  /// No description provided for @setMonthStartDayBody.
  ///
  /// In uz, this message translates to:
  /// **'Masalan maosh 5-sanada bo\'lsa, moliyaviy oy 5-dan boshlanadi.'**
  String get setMonthStartDayBody;

  /// No description provided for @setWeekStartDay.
  ///
  /// In uz, this message translates to:
  /// **'Haftaning boshlanish kuni'**
  String get setWeekStartDay;

  /// No description provided for @setMonday.
  ///
  /// In uz, this message translates to:
  /// **'Dushanba'**
  String get setMonday;

  /// No description provided for @setSunday.
  ///
  /// In uz, this message translates to:
  /// **'Yakshanba'**
  String get setSunday;

  /// No description provided for @setManageAccounts.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblar'**
  String get setManageAccounts;

  /// No description provided for @setManageCategories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get setManageCategories;

  /// No description provided for @setBackup.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira nusxa va eksport'**
  String get setBackup;

  /// No description provided for @setWipe.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ma\'lumotni o\'chirish'**
  String get setWipe;

  /// No description provided for @setWipeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hammasini o\'chirasizmi?'**
  String get setWipeTitle;

  /// No description provided for @setWipeBody.
  ///
  /// In uz, this message translates to:
  /// **'Barcha hisoblar, kategoriyalar va yozuvlar butunlay o\'chadi. Bu amalni bekor qilish mumkin emas.'**
  String get setWipeBody;

  /// No description provided for @setWipeConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get setWipeConfirmTitle;

  /// No description provided for @setWipeConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun quyida {word} so\'zini kiriting.'**
  String setWipeConfirmBody(String word);

  /// No description provided for @setWipeWord.
  ///
  /// In uz, this message translates to:
  /// **'O\'CHIRISH'**
  String get setWipeWord;

  /// No description provided for @setWipeDone.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ma\'lumot o\'chirildi'**
  String get setWipeDone;

  /// No description provided for @setVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya'**
  String get setVersion;

  /// No description provided for @setPrivacyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik'**
  String get setPrivacyTitle;

  /// No description provided for @setPrivacyBody.
  ///
  /// In uz, this message translates to:
  /// **'Finora hech qanday ma\'lumot yig\'maydi va tashqariga yubormaydi. Hamma narsa shu qurilmada qoladi.'**
  String get setPrivacyBody;

  /// No description provided for @bkpTitle.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira nusxa'**
  String get bkpTitle;

  /// No description provided for @bkpSectionBackup.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira'**
  String get bkpSectionBackup;

  /// No description provided for @bkpSectionExport.
  ///
  /// In uz, this message translates to:
  /// **'Eksport'**
  String get bkpSectionExport;

  /// No description provided for @bkpCreate.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira nusxa yaratish'**
  String get bkpCreate;

  /// No description provided for @bkpCreateBody.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ma\'lumotni bitta faylga saqlaydi. Faylni Telegram, Drive yoki emailga yuborib qo\'ying.'**
  String get bkpCreateBody;

  /// No description provided for @bkpRestore.
  ///
  /// In uz, this message translates to:
  /// **'Fayldan tiklash'**
  String get bkpRestore;

  /// No description provided for @bkpRestoreBody.
  ///
  /// In uz, this message translates to:
  /// **'Telefon almashganda yoki ilovani qayta o\'rnatganda kerak bo\'ladi.'**
  String get bkpRestoreBody;

  /// No description provided for @bkpExportCsv.
  ///
  /// In uz, this message translates to:
  /// **'CSV\'ga eksport'**
  String get bkpExportCsv;

  /// No description provided for @bkpExportCsvBody.
  ///
  /// In uz, this message translates to:
  /// **'Tanlangan davrdagi yozuvlarni jadval sifatida saqlash.'**
  String get bkpExportCsvBody;

  /// No description provided for @bkpLast.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi zaxira: {date}'**
  String bkpLast(String date);

  /// No description provided for @bkpNever.
  ///
  /// In uz, this message translates to:
  /// **'Hali zaxira nusxa olinmagan'**
  String get bkpNever;

  /// No description provided for @bkpReminder.
  ///
  /// In uz, this message translates to:
  /// **'Oxirgi zaxiradan {days} kun o\'tdi. Nusxa olib qo\'ying.'**
  String bkpReminder(int days);

  /// No description provided for @bkpCreated.
  ///
  /// In uz, this message translates to:
  /// **'Zaxira nusxa tayyor'**
  String get bkpCreated;

  /// No description provided for @bkpShareSubject.
  ///
  /// In uz, this message translates to:
  /// **'Finora zaxira nusxasi'**
  String get bkpShareSubject;

  /// No description provided for @bkpRestoreTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotni tiklaysizmi?'**
  String get bkpRestoreTitle;

  /// No description provided for @bkpRestoreConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Hozirgi barcha ma\'lumot fayldagisi bilan almashtiriladi.'**
  String get bkpRestoreConfirmBody;

  /// No description provided for @bkpRestored.
  ///
  /// In uz, this message translates to:
  /// **'Tiklandi: {accounts} hisob, {transactions} yozuv'**
  String bkpRestored(int accounts, int transactions);

  /// No description provided for @bkpInvalidFile.
  ///
  /// In uz, this message translates to:
  /// **'Fayl o\'qilmadi — Finora zaxira fayli emas'**
  String get bkpInvalidFile;

  /// No description provided for @bkpVersionMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Fayl versiyasi mos emas. Ilovani yangilang.'**
  String get bkpVersionMismatch;

  /// No description provided for @bkpExported.
  ///
  /// In uz, this message translates to:
  /// **'Fayl tayyor'**
  String get bkpExported;

  /// No description provided for @seedCatFood.
  ///
  /// In uz, this message translates to:
  /// **'Oziq-ovqat'**
  String get seedCatFood;

  /// No description provided for @seedCatTransport.
  ///
  /// In uz, this message translates to:
  /// **'Transport'**
  String get seedCatTransport;

  /// No description provided for @seedCatHousing.
  ///
  /// In uz, this message translates to:
  /// **'Uy-joy / Ijara'**
  String get seedCatHousing;

  /// No description provided for @seedCatUtilities.
  ///
  /// In uz, this message translates to:
  /// **'Kommunal'**
  String get seedCatUtilities;

  /// No description provided for @seedCatInternet.
  ///
  /// In uz, this message translates to:
  /// **'Aloqa / Internet'**
  String get seedCatInternet;

  /// No description provided for @seedCatClothes.
  ///
  /// In uz, this message translates to:
  /// **'Kiyim'**
  String get seedCatClothes;

  /// No description provided for @seedCatHealth.
  ///
  /// In uz, this message translates to:
  /// **'Sog\'liq'**
  String get seedCatHealth;

  /// No description provided for @seedCatEducation.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'lim'**
  String get seedCatEducation;

  /// No description provided for @seedCatFun.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'ngilochar'**
  String get seedCatFun;

  /// No description provided for @seedCatCafe.
  ///
  /// In uz, this message translates to:
  /// **'Restoran / Kafe'**
  String get seedCatCafe;

  /// No description provided for @seedCatGifts.
  ///
  /// In uz, this message translates to:
  /// **'Sovg\'alar'**
  String get seedCatGifts;

  /// No description provided for @seedCatFamily.
  ///
  /// In uz, this message translates to:
  /// **'Oila'**
  String get seedCatFamily;

  /// No description provided for @seedCatSubscription.
  ///
  /// In uz, this message translates to:
  /// **'Obuna'**
  String get seedCatSubscription;

  /// No description provided for @seedCatOtherExpense.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get seedCatOtherExpense;

  /// No description provided for @seedCatSalary.
  ///
  /// In uz, this message translates to:
  /// **'Maosh'**
  String get seedCatSalary;

  /// No description provided for @seedCatScholarship.
  ///
  /// In uz, this message translates to:
  /// **'Stipendiya'**
  String get seedCatScholarship;

  /// No description provided for @seedCatFreelance.
  ///
  /// In uz, this message translates to:
  /// **'Frilans'**
  String get seedCatFreelance;

  /// No description provided for @seedCatGift.
  ///
  /// In uz, this message translates to:
  /// **'Sovg\'a'**
  String get seedCatGift;

  /// No description provided for @seedCatBusiness.
  ///
  /// In uz, this message translates to:
  /// **'Biznes'**
  String get seedCatBusiness;

  /// No description provided for @seedCatInvestment.
  ///
  /// In uz, this message translates to:
  /// **'Investitsiya'**
  String get seedCatInvestment;

  /// No description provided for @seedCatOtherIncome.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get seedCatOtherIncome;

  /// No description provided for @seedAccCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd'**
  String get seedAccCash;

  /// No description provided for @seedAccCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta'**
  String get seedAccCard;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'ru':
      return AppL10nRu();
    case 'uz':
      return AppL10nUz();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
