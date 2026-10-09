// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finora';

  @override
  String get brandTagline => 'Your money, in control';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionPrevious => 'Previous';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get actionArchive => 'Archive';

  @override
  String get actionUnarchive => 'Unarchive';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionFilter => 'Filter';

  @override
  String get actionClear => 'Clear';

  @override
  String get actionApply => 'Apply';

  @override
  String get actionContinue => 'Continue';

  @override
  String get labelAll => 'All';

  @override
  String get labelTotal => 'Total';

  @override
  String get labelToday => 'Today';

  @override
  String get labelYesterday => 'Yesterday';

  @override
  String get labelRequired => 'Required field';

  @override
  String get labelOptional => 'optional';

  @override
  String get labelNone => 'None';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get navHome => 'Home';

  @override
  String get navTransactions => 'History';

  @override
  String get navStats => 'Statistics';

  @override
  String get navMore => 'More';

  @override
  String get onbWelcomeTitle => 'Welcome to Finora';

  @override
  String get onbWelcomeBody =>
      'Stay on top of your money: where it came from, where it went, what is left.';

  @override
  String get onbPrivacyNote =>
      'All data stays on your phone. No internet, no sign-up, no server.';

  @override
  String get onbStart => 'Get started';

  @override
  String onbStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get onbLanguageTitle => 'Choose a language';

  @override
  String get onbCurrencyTitle => 'Main currency';

  @override
  String get onbCurrencyBody => 'Your total balance is shown in this currency.';

  @override
  String get onbBalanceTitle => 'Starting balance';

  @override
  String get onbBalanceBody =>
      'Enter how much cash and card money you have right now. You can change it later.';

  @override
  String get onbCashQuestion => 'How much cash do you have?';

  @override
  String get onbCardQuestion => 'How much is on your cards?';

  @override
  String get onbAddCard => 'Add a card';

  @override
  String get onbCardNameHint => 'Uzcard, Humo, Kapital...';

  @override
  String get onbLater => 'I\'ll add it later';

  @override
  String get onbExtrasTitle => 'Extras';

  @override
  String get onbReminder => 'Daily reminder';

  @override
  String get onbReminderBody =>
      'We\'ll remind you to log your spending each day.';

  @override
  String get onbFinish => 'All set, let\'s go';

  @override
  String get dashTotalBalance => 'Total balance';

  @override
  String get dashHideBalance => 'Hide balance';

  @override
  String get dashShowBalance => 'Show balance';

  @override
  String get dashMyAccounts => 'My accounts';

  @override
  String get dashThisPeriod => 'This month';

  @override
  String get dashIncome => 'Income';

  @override
  String get dashExpense => 'Expense';

  @override
  String get dashDifference => 'Difference';

  @override
  String get dashRecent => 'Recent records';

  @override
  String get dashSeeAll => 'See all';

  @override
  String get dashEmptyTitle => 'No records yet';

  @override
  String get dashEmptyBody =>
      'Add your first income or expense — the statistics build themselves.';

  @override
  String get dashAddFirst => 'Add the first record';

  @override
  String get txIncome => 'Income';

  @override
  String get txExpense => 'Expense';

  @override
  String get txTransfer => 'Transfer';

  @override
  String get txType => 'Type';

  @override
  String get txSortBy => 'Sort by';

  @override
  String get txNew => 'New record';

  @override
  String get txEdit => 'Edit record';

  @override
  String get txDetails => 'Record details';

  @override
  String get txAmount => 'Amount';

  @override
  String get txCategory => 'Category';

  @override
  String get txAccount => 'Account';

  @override
  String get txFromAccount => 'From account';

  @override
  String get txToAccount => 'To account';

  @override
  String get txDate => 'Date';

  @override
  String get txTime => 'Time';

  @override
  String get txNote => 'Note';

  @override
  String get txNoteHint => 'What was it for?';

  @override
  String get txRate => 'Rate';

  @override
  String txRateHint(String from, String to) {
    return '1 $from = ? $to';
  }

  @override
  String txConverted(String amount) {
    return 'Arrives: $amount';
  }

  @override
  String get txSelectCategory => 'Select a category';

  @override
  String get txSelectAccount => 'Select an account';

  @override
  String get txNoCategory => 'Uncategorised';

  @override
  String get txErrorAmount => 'Enter an amount';

  @override
  String get txErrorAccount => 'Select an account';

  @override
  String get txErrorCategory => 'Select a category';

  @override
  String get txErrorSameAccount => 'Cannot transfer to the same account';

  @override
  String get txErrorRate => 'Enter the rate';

  @override
  String get txSaved => 'Saved';

  @override
  String get txDeleted => 'Deleted';

  @override
  String get txDeleteTitle => 'Delete this record?';

  @override
  String get txDeleteBody =>
      'The balance will be recalculated. You can undo this.';

  @override
  String get txListTitle => 'History';

  @override
  String get txEmptyTitle => 'No records found';

  @override
  String get txEmptyBody => 'Try different filters or add a new record.';

  @override
  String get txSearchHint => 'Search by note or category';

  @override
  String get txDayTotal => 'Day total';

  @override
  String get txSwipeHint => 'Swipe left to delete, right to edit';

  @override
  String txCalcResult(String value) {
    return '= $value';
  }

  @override
  String get accTitle => 'Accounts';

  @override
  String get accNew => 'New account';

  @override
  String get accEdit => 'Edit account';

  @override
  String get accName => 'Name';

  @override
  String get accNameHint => 'Cash, Uzcard, Humo...';

  @override
  String get accType => 'Type';

  @override
  String get accCurrency => 'Currency';

  @override
  String get accInitialBalance => 'Starting balance';

  @override
  String get accIcon => 'Icon';

  @override
  String get accColor => 'Colour';

  @override
  String get accIncludeInTotal => 'Include in total balance';

  @override
  String get accIncludeInTotalBody =>
      'When off, this account is left out of the total.';

  @override
  String get accArchived => 'Archived';

  @override
  String get accShowArchived => 'Show archived';

  @override
  String get accErrorName => 'Enter an account name';

  @override
  String get accReconcile => 'Reconcile balance';

  @override
  String get accReconcileBody =>
      'Enter the real balance — the app records the difference as an \"Adjustment\".';

  @override
  String get accRealBalance => 'Real balance';

  @override
  String get accAdjustmentNote => 'Balance adjustment';

  @override
  String get accReconcileNoDiff => 'No difference — everything matches';

  @override
  String accReconcileDone(String amount) {
    return 'Adjustment recorded: $amount';
  }

  @override
  String get accDeleteTitle => 'Delete this account?';

  @override
  String get accDeleteBody =>
      'The account will be removed for good. This cannot be undone.';

  @override
  String get accDeleteBlockedTitle => 'Cannot delete';

  @override
  String accDeleteBlockedBody(int count) {
    return 'This account has $count records. Archive it instead to keep the history.';
  }

  @override
  String get accEmptyTitle => 'No accounts';

  @override
  String get accEmptyBody => 'Add cash, a card or a bank account.';

  @override
  String accTxCount(int count) {
    return '$count records';
  }

  @override
  String get accReorderHint => 'Press and drag to reorder';

  @override
  String get accTypeCash => 'Cash';

  @override
  String get accTypeCard => 'Card';

  @override
  String get accTypeBank => 'Bank account';

  @override
  String get accTypeSavings => 'Savings';

  @override
  String get accTypeEwallet => 'E-wallet';

  @override
  String get accTypeOther => 'Other';

  @override
  String get catTitle => 'Categories';

  @override
  String get catNew => 'New category';

  @override
  String get catEdit => 'Edit category';

  @override
  String get catName => 'Name';

  @override
  String get catKind => 'Type';

  @override
  String get catIcon => 'Icon';

  @override
  String get catColor => 'Colour';

  @override
  String get catParent => 'Parent category';

  @override
  String get catNoParent => 'Top-level category';

  @override
  String get catArchived => 'Archived';

  @override
  String get catShowArchived => 'Show archived';

  @override
  String get catErrorName => 'Enter a category name';

  @override
  String get catDeleteTitle => 'Delete this category?';

  @override
  String catDeleteBody(int count) {
    return 'Its $count records move to \"Uncategorised\".';
  }

  @override
  String get catEmptyTitle => 'No categories';

  @override
  String get catEmptyBody => 'Add your first category.';

  @override
  String get statTitle => 'Statistics';

  @override
  String get statTabOverview => 'Overview';

  @override
  String get statTabCategories => 'Categories';

  @override
  String get statTabTrend => 'Trend';

  @override
  String get statPeriodDay => 'Day';

  @override
  String get statPeriodWeek => 'Week';

  @override
  String get statPeriodMonth => 'Month';

  @override
  String get statPeriodYear => 'Year';

  @override
  String get statPeriodCustom => 'Range';

  @override
  String get statPickRange => 'Pick a range';

  @override
  String get statTotalIncome => 'Total income';

  @override
  String get statTotalExpense => 'Total expense';

  @override
  String get statNet => 'Net result';

  @override
  String get statAvgPerDay => 'Average daily spend';

  @override
  String get statBiggestExpense => 'Largest expense';

  @override
  String get statTopCategory => 'Top spending category';

  @override
  String get statSavingsRate => 'Savings rate';

  @override
  String get statByCategory => 'Expenses by category';

  @override
  String get statByAccount => 'By account';

  @override
  String get statIncomeVsExpense => 'Income vs expense';

  @override
  String get statBalanceTrend => 'Balance trend';

  @override
  String get statVsPrevious => 'vs previous period';

  @override
  String get statMissingRate =>
      'No exchange rate set for some currencies — amounts counted 1:1.';

  @override
  String get statEmptyTitle => 'No data for this period';

  @override
  String get statEmptyBody => 'Change the period or add a record.';

  @override
  String statShareOfTotal(String percent) {
    return '$percent% of all expenses';
  }

  @override
  String get setTitle => 'Settings';

  @override
  String get setSectionGeneral => 'General';

  @override
  String get setSectionAppearance => 'Appearance';

  @override
  String get setSectionData => 'Data';

  @override
  String get setSectionAbout => 'About';

  @override
  String get setLanguage => 'Language';

  @override
  String get setTheme => 'Theme';

  @override
  String get setThemeLight => 'Light';

  @override
  String get setThemeDark => 'Dark';

  @override
  String get setThemeSystem => 'Follow system';

  @override
  String get setCurrency => 'Main currency';

  @override
  String get setMonthStartDay => 'Month starts on day';

  @override
  String get setMonthStartDayBody =>
      'If you are paid on the 5th, your financial month can start on the 5th.';

  @override
  String get setWeekStartDay => 'Week starts on';

  @override
  String get setMonday => 'Monday';

  @override
  String get setSunday => 'Sunday';

  @override
  String get setManageAccounts => 'Accounts';

  @override
  String get setManageCategories => 'Categories';

  @override
  String get setBackup => 'Backup and export';

  @override
  String get setWipe => 'Delete all data';

  @override
  String get setWipeTitle => 'Delete everything?';

  @override
  String get setWipeBody =>
      'All accounts, categories and records will be permanently removed.';

  @override
  String get setWipeConfirmTitle => 'Confirm';

  @override
  String setWipeConfirmBody(String word) {
    return 'Type $word below to continue.';
  }

  @override
  String get setWipeWord => 'DELETE';

  @override
  String get setWipeDone => 'All data deleted';

  @override
  String get setVersion => 'Version';

  @override
  String get setPrivacyTitle => 'Privacy';

  @override
  String get setPrivacyBody =>
      'Finora collects nothing and sends nothing. Everything stays on this device.';

  @override
  String get bkpTitle => 'Backup';

  @override
  String get bkpSectionBackup => 'Backup';

  @override
  String get bkpSectionExport => 'Export';

  @override
  String get bkpCreate => 'Create a backup';

  @override
  String get bkpCreateBody =>
      'Saves all data into a single file. Send it to Telegram, Drive or email.';

  @override
  String get bkpRestore => 'Restore from a file';

  @override
  String get bkpRestoreBody =>
      'Useful when you change phones or reinstall the app.';

  @override
  String get bkpExportCsv => 'Export to CSV';

  @override
  String get bkpExportCsvBody =>
      'Save the records of the selected period as a spreadsheet.';

  @override
  String bkpLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get bkpNever => 'No backup yet';

  @override
  String bkpReminder(int days) {
    return 'Your last backup was $days days ago. Make a new one.';
  }

  @override
  String get bkpCreated => 'Backup ready';

  @override
  String get bkpShareSubject => 'Finora backup';

  @override
  String get bkpRestoreTitle => 'Restore data?';

  @override
  String get bkpRestoreConfirmBody =>
      'All current data will be replaced with the contents of the file.';

  @override
  String bkpRestored(int accounts, int transactions) {
    return 'Restored: $accounts accounts, $transactions records';
  }

  @override
  String get bkpInvalidFile =>
      'Could not read the file — it is not a Finora backup';

  @override
  String get bkpVersionMismatch =>
      'This file version is not supported. Update the app.';

  @override
  String get bkpExported => 'File ready';

  @override
  String get seedCatFood => 'Groceries';

  @override
  String get seedCatTransport => 'Transport';

  @override
  String get seedCatHousing => 'Housing / Rent';

  @override
  String get seedCatUtilities => 'Utilities';

  @override
  String get seedCatInternet => 'Phone / Internet';

  @override
  String get seedCatClothes => 'Clothes';

  @override
  String get seedCatHealth => 'Health';

  @override
  String get seedCatEducation => 'Education';

  @override
  String get seedCatFun => 'Entertainment';

  @override
  String get seedCatCafe => 'Cafes / Restaurants';

  @override
  String get seedCatGifts => 'Gifts';

  @override
  String get seedCatFamily => 'Family';

  @override
  String get seedCatSubscription => 'Subscriptions';

  @override
  String get seedCatOtherExpense => 'Other';

  @override
  String get seedCatSalary => 'Salary';

  @override
  String get seedCatScholarship => 'Scholarship';

  @override
  String get seedCatFreelance => 'Freelance';

  @override
  String get seedCatGift => 'Gift';

  @override
  String get seedCatBusiness => 'Business';

  @override
  String get seedCatInvestment => 'Investments';

  @override
  String get seedCatOtherIncome => 'Other';

  @override
  String get seedAccCash => 'Cash';

  @override
  String get seedAccCard => 'Card';
}
