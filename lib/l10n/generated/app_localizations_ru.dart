// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Finora';

  @override
  String get brandTagline => 'Деньги под контролем';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Изменить';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionNext => 'Далее';

  @override
  String get actionPrevious => 'Назад';

  @override
  String get actionSkip => 'Пропустить';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionOk => 'ОК';

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionDuplicate => 'Дублировать';

  @override
  String get actionArchive => 'В архив';

  @override
  String get actionUnarchive => 'Из архива';

  @override
  String get actionSearch => 'Поиск';

  @override
  String get actionFilter => 'Фильтр';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionApply => 'Применить';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get labelAll => 'Все';

  @override
  String get labelTotal => 'Всего';

  @override
  String get labelToday => 'Сегодня';

  @override
  String get labelYesterday => 'Вчера';

  @override
  String get labelRequired => 'Обязательное поле';

  @override
  String get labelOptional => 'необязательно';

  @override
  String get labelNone => 'Нет';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get navHome => 'Главная';

  @override
  String get navTransactions => 'История';

  @override
  String get navStats => 'Статистика';

  @override
  String get navMore => 'Ещё';

  @override
  String get onbWelcomeTitle => 'Добро пожаловать в Finora';

  @override
  String get onbWelcomeBody =>
      'Контролируйте деньги: откуда пришли, на что ушли, сколько осталось.';

  @override
  String get onbPrivacyNote =>
      'Все данные хранятся только на вашем телефоне. Интернет, регистрация и сервер не нужны.';

  @override
  String get onbStart => 'Начать';

  @override
  String onbStepOf(int step, int total) {
    return 'Шаг $step из $total';
  }

  @override
  String get onbLanguageTitle => 'Выберите язык';

  @override
  String get onbCurrencyTitle => 'Основная валюта';

  @override
  String get onbCurrencyBody => 'Общий баланс будет показан в этой валюте.';

  @override
  String get onbBalanceTitle => 'Начальный остаток';

  @override
  String get onbBalanceBody =>
      'Укажите, сколько денег у вас сейчас наличными и на картах. Это можно изменить позже.';

  @override
  String get onbCashQuestion => 'Сколько наличных у вас на руках?';

  @override
  String get onbCardQuestion => 'Сколько на картах?';

  @override
  String get onbAddCard => 'Добавить карту';

  @override
  String get onbCardNameHint => 'Uzcard, Humo, Kapital...';

  @override
  String get onbLater => 'Добавлю позже';

  @override
  String get onbExtrasTitle => 'Дополнительно';

  @override
  String get onbReminder => 'Ежедневное напоминание';

  @override
  String get onbReminderBody => 'Будем напоминать вносить расходы каждый день.';

  @override
  String get onbFinish => 'Готово, начнём';

  @override
  String get dashTotalBalance => 'Общий баланс';

  @override
  String get dashHideBalance => 'Скрыть баланс';

  @override
  String get dashShowBalance => 'Показать баланс';

  @override
  String get dashMyAccounts => 'Мои счета';

  @override
  String get dashThisPeriod => 'Текущий месяц';

  @override
  String get dashIncome => 'Доход';

  @override
  String get dashExpense => 'Расход';

  @override
  String get dashDifference => 'Разница';

  @override
  String get dashRecent => 'Последние записи';

  @override
  String get dashSeeAll => 'Показать все';

  @override
  String get dashEmptyTitle => 'Записей пока нет';

  @override
  String get dashEmptyBody =>
      'Добавьте первый доход или расход — статистика появится сама.';

  @override
  String get dashAddFirst => 'Добавить первую запись';

  @override
  String get txIncome => 'Доход';

  @override
  String get txExpense => 'Расход';

  @override
  String get txTransfer => 'Перевод';

  @override
  String get txType => 'Тип';

  @override
  String get txSortBy => 'Сортировка';

  @override
  String get txNew => 'Новая запись';

  @override
  String get txEdit => 'Изменить запись';

  @override
  String get txDetails => 'Детали записи';

  @override
  String get txAmount => 'Сумма';

  @override
  String get txCategory => 'Категория';

  @override
  String get txAccount => 'Счёт';

  @override
  String get txFromAccount => 'Со счёта';

  @override
  String get txToAccount => 'На счёт';

  @override
  String get txDate => 'Дата';

  @override
  String get txTime => 'Время';

  @override
  String get txNote => 'Заметка';

  @override
  String get txNoteHint => 'На что потратили?';

  @override
  String get txRate => 'Курс';

  @override
  String txRateHint(String from, String to) {
    return '1 $from = ? $to';
  }

  @override
  String txConverted(String amount) {
    return 'Поступит: $amount';
  }

  @override
  String get txSelectCategory => 'Выберите категорию';

  @override
  String get txSelectAccount => 'Выберите счёт';

  @override
  String get txNoCategory => 'Без категории';

  @override
  String get txErrorAmount => 'Введите сумму';

  @override
  String get txErrorAccount => 'Выберите счёт';

  @override
  String get txErrorCategory => 'Выберите категорию';

  @override
  String get txErrorSameAccount => 'Нельзя перевести на тот же счёт';

  @override
  String get txErrorRate => 'Введите курс';

  @override
  String get txSaved => 'Сохранено';

  @override
  String get txDeleted => 'Удалено';

  @override
  String get txDeleteTitle => 'Удалить запись?';

  @override
  String get txDeleteBody =>
      'Баланс будет пересчитан. Действие можно отменить.';

  @override
  String get txListTitle => 'История';

  @override
  String get txEmptyTitle => 'Записи не найдены';

  @override
  String get txEmptyBody => 'Измените фильтры или добавьте новую запись.';

  @override
  String get txSearchHint => 'Поиск по заметке или категории';

  @override
  String get txDayTotal => 'Итого за день';

  @override
  String get txSwipeHint => 'Свайп влево — удалить, вправо — изменить';

  @override
  String txCalcResult(String value) {
    return '= $value';
  }

  @override
  String get accTitle => 'Счета';

  @override
  String get accNew => 'Новый счёт';

  @override
  String get accEdit => 'Изменить счёт';

  @override
  String get accName => 'Название';

  @override
  String get accNameHint => 'Наличные, Uzcard, Humo...';

  @override
  String get accType => 'Тип';

  @override
  String get accCurrency => 'Валюта';

  @override
  String get accInitialBalance => 'Начальный остаток';

  @override
  String get accIcon => 'Иконка';

  @override
  String get accColor => 'Цвет';

  @override
  String get accIncludeInTotal => 'Учитывать в общем балансе';

  @override
  String get accIncludeInTotalBody =>
      'Если выключено, счёт не попадёт в общую сумму.';

  @override
  String get accArchived => 'В архиве';

  @override
  String get accShowArchived => 'Показать архивные';

  @override
  String get accErrorName => 'Введите название счёта';

  @override
  String get accReconcile => 'Скорректировать баланс';

  @override
  String get accReconcileBody =>
      'Введите фактический остаток — приложение добавит разницу как запись «Корректировка».';

  @override
  String get accRealBalance => 'Фактический остаток';

  @override
  String get accAdjustmentNote => 'Корректировка баланса';

  @override
  String get accReconcileNoDiff => 'Разницы нет — всё совпадает';

  @override
  String accReconcileDone(String amount) {
    return 'Добавлена корректировка: $amount';
  }

  @override
  String get accDeleteTitle => 'Удалить счёт?';

  @override
  String get accDeleteBody =>
      'Счёт будет удалён полностью. Это действие нельзя отменить.';

  @override
  String get accDeleteBlockedTitle => 'Удалить нельзя';

  @override
  String accDeleteBlockedBody(int count) {
    return 'На этом счёте $count записей. Чтобы сохранить историю, отправьте счёт в архив.';
  }

  @override
  String get accEmptyTitle => 'Счетов нет';

  @override
  String get accEmptyBody => 'Добавьте наличные, карту или банковский счёт.';

  @override
  String accTxCount(int count) {
    return '$count записей';
  }

  @override
  String get accReorderHint => 'Зажмите и перетащите, чтобы изменить порядок';

  @override
  String get accTypeCash => 'Наличные';

  @override
  String get accTypeCard => 'Карта';

  @override
  String get accTypeBank => 'Банковский счёт';

  @override
  String get accTypeSavings => 'Вклад';

  @override
  String get accTypeEwallet => 'Электронный кошелёк';

  @override
  String get accTypeOther => 'Другое';

  @override
  String get catTitle => 'Категории';

  @override
  String get catNew => 'Новая категория';

  @override
  String get catEdit => 'Изменить категорию';

  @override
  String get catName => 'Название';

  @override
  String get catKind => 'Тип';

  @override
  String get catIcon => 'Иконка';

  @override
  String get catColor => 'Цвет';

  @override
  String get catParent => 'Родительская категория';

  @override
  String get catNoParent => 'Основная категория';

  @override
  String get catArchived => 'В архиве';

  @override
  String get catShowArchived => 'Показать архивные';

  @override
  String get catErrorName => 'Введите название категории';

  @override
  String get catDeleteTitle => 'Удалить категорию?';

  @override
  String catDeleteBody(int count) {
    return 'Связанные $count записей перейдут в «Без категории».';
  }

  @override
  String get catEmptyTitle => 'Категорий нет';

  @override
  String get catEmptyBody => 'Добавьте первую категорию.';

  @override
  String get statTitle => 'Статистика';

  @override
  String get statTabOverview => 'Обзор';

  @override
  String get statTabCategories => 'Категории';

  @override
  String get statTabTrend => 'Тренд';

  @override
  String get statPeriodDay => 'День';

  @override
  String get statPeriodWeek => 'Неделя';

  @override
  String get statPeriodMonth => 'Месяц';

  @override
  String get statPeriodYear => 'Год';

  @override
  String get statPeriodCustom => 'Период';

  @override
  String get statPickRange => 'Выберите период';

  @override
  String get statTotalIncome => 'Всего доходов';

  @override
  String get statTotalExpense => 'Всего расходов';

  @override
  String get statNet => 'Чистый результат';

  @override
  String get statAvgPerDay => 'Средний расход в день';

  @override
  String get statBiggestExpense => 'Самый большой расход';

  @override
  String get statTopCategory => 'Главная категория расходов';

  @override
  String get statSavingsRate => 'Норма сбережений';

  @override
  String get statByCategory => 'Расходы по категориям';

  @override
  String get statByAccount => 'По счетам';

  @override
  String get statIncomeVsExpense => 'Доходы и расходы';

  @override
  String get statBalanceTrend => 'Динамика баланса';

  @override
  String get statVsPrevious => 'к предыдущему периоду';

  @override
  String get statMissingRate =>
      'Для некоторых валют не задан курс — суммы учтены 1:1.';

  @override
  String get statEmptyTitle => 'За этот период данных нет';

  @override
  String get statEmptyBody => 'Измените период или добавьте запись.';

  @override
  String statShareOfTotal(String percent) {
    return '$percent% от всех расходов';
  }

  @override
  String get setTitle => 'Настройки';

  @override
  String get setSectionGeneral => 'Общие';

  @override
  String get setSectionAppearance => 'Внешний вид';

  @override
  String get setSectionData => 'Данные';

  @override
  String get setSectionAbout => 'О приложении';

  @override
  String get setLanguage => 'Язык';

  @override
  String get setTheme => 'Тема';

  @override
  String get setThemeLight => 'Светлая';

  @override
  String get setThemeDark => 'Тёмная';

  @override
  String get setThemeSystem => 'Как в системе';

  @override
  String get setCurrency => 'Основная валюта';

  @override
  String get setMonthStartDay => 'День начала месяца';

  @override
  String get setMonthStartDayBody =>
      'Например, если зарплата 5-го, финансовый месяц начнётся с 5-го.';

  @override
  String get setWeekStartDay => 'День начала недели';

  @override
  String get setMonday => 'Понедельник';

  @override
  String get setSunday => 'Воскресенье';

  @override
  String get setManageAccounts => 'Счета';

  @override
  String get setManageCategories => 'Категории';

  @override
  String get setBackup => 'Резервная копия и экспорт';

  @override
  String get setWipe => 'Удалить все данные';

  @override
  String get setWipeTitle => 'Удалить всё?';

  @override
  String get setWipeBody =>
      'Все счета, категории и записи будут удалены безвозвратно.';

  @override
  String get setWipeConfirmTitle => 'Подтверждение';

  @override
  String setWipeConfirmBody(String word) {
    return 'Чтобы продолжить, введите слово $word.';
  }

  @override
  String get setWipeWord => 'УДАЛИТЬ';

  @override
  String get setWipeDone => 'Все данные удалены';

  @override
  String get setVersion => 'Версия';

  @override
  String get setPrivacyTitle => 'Приватность';

  @override
  String get setPrivacyBody =>
      'Finora не собирает и не отправляет данные. Всё остаётся на этом устройстве.';

  @override
  String get bkpTitle => 'Резервная копия';

  @override
  String get bkpSectionBackup => 'Резервная копия';

  @override
  String get bkpSectionExport => 'Экспорт';

  @override
  String get bkpCreate => 'Создать резервную копию';

  @override
  String get bkpCreateBody =>
      'Сохраняет все данные в один файл. Отправьте файл в Telegram, Drive или на email.';

  @override
  String get bkpRestore => 'Восстановить из файла';

  @override
  String get bkpRestoreBody =>
      'Понадобится при смене телефона или переустановке приложения.';

  @override
  String get bkpExportCsv => 'Экспорт в CSV';

  @override
  String get bkpExportCsvBody =>
      'Сохранить записи выбранного периода таблицей.';

  @override
  String bkpLast(String date) {
    return 'Последняя копия: $date';
  }

  @override
  String get bkpNever => 'Резервная копия ещё не создавалась';

  @override
  String bkpReminder(int days) {
    return 'С последней копии прошло $days дней. Сделайте новую.';
  }

  @override
  String get bkpCreated => 'Резервная копия готова';

  @override
  String get bkpShareSubject => 'Резервная копия Finora';

  @override
  String get bkpRestoreTitle => 'Восстановить данные?';

  @override
  String get bkpRestoreConfirmBody =>
      'Все текущие данные будут заменены данными из файла.';

  @override
  String bkpRestored(int accounts, int transactions) {
    return 'Восстановлено: счетов — $accounts, записей — $transactions';
  }

  @override
  String get bkpInvalidFile =>
      'Файл не прочитан — это не резервная копия Finora';

  @override
  String get bkpVersionMismatch =>
      'Версия файла не подходит. Обновите приложение.';

  @override
  String get bkpExported => 'Файл готов';

  @override
  String get seedCatFood => 'Продукты';

  @override
  String get seedCatTransport => 'Транспорт';

  @override
  String get seedCatHousing => 'Жильё / Аренда';

  @override
  String get seedCatUtilities => 'Коммунальные';

  @override
  String get seedCatInternet => 'Связь / Интернет';

  @override
  String get seedCatClothes => 'Одежда';

  @override
  String get seedCatHealth => 'Здоровье';

  @override
  String get seedCatEducation => 'Образование';

  @override
  String get seedCatFun => 'Развлечения';

  @override
  String get seedCatCafe => 'Кафе / Рестораны';

  @override
  String get seedCatGifts => 'Подарки';

  @override
  String get seedCatFamily => 'Семья';

  @override
  String get seedCatSubscription => 'Подписки';

  @override
  String get seedCatOtherExpense => 'Другое';

  @override
  String get seedCatSalary => 'Зарплата';

  @override
  String get seedCatScholarship => 'Стипендия';

  @override
  String get seedCatFreelance => 'Фриланс';

  @override
  String get seedCatGift => 'Подарок';

  @override
  String get seedCatBusiness => 'Бизнес';

  @override
  String get seedCatInvestment => 'Инвестиции';

  @override
  String get seedCatOtherIncome => 'Другое';

  @override
  String get seedAccCash => 'Наличные';

  @override
  String get seedAccCard => 'Карта';
}
