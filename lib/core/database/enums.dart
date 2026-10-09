/// Bazada `textEnum` sifatida saqlanadigan sanab o'tilgan turlar.
///
/// Nomlar bazaga matn ko'rinishida yoziladi — shuning uchun mavjud
/// qiymatlarni **qayta nomlash mumkin emas** (faqat yangisini qo'shish).
library;

enum AccountType { cash, card, bank, savings, ewallet, other }

enum CategoryKind { income, expense }

enum TransactionType { income, expense, transfer }

enum BudgetPeriod { weekly, monthly }

enum DebtDirection { iOwe, owedToMe }

enum DebtStatus { open, closed }

enum RecurringFrequency { daily, weekly, monthly, yearly }

enum RecurringMode { auto, confirm }
