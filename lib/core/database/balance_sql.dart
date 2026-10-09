/// Balans **hech qachon saqlanmaydi** — har safar tranzaksiyalardan
/// hisoblanadi. Shunda tahrirlash/o'chirishda "yolg'on qoldiq" chiqmaydi.
///
/// ```
/// balance = initial_balance
///         + SUM(income)            // shu hisobga
///         - SUM(expense)           // shu hisobdan
///         - SUM(transfer out)      // shu hisobdan chiqqan
///         + SUM(transfer in)       // shu hisobga kirgan (kurs bilan)
/// ```
library;

/// Qoldiq ifodasi. `dateBound` — qo'shimcha `AND t.date_time <= ?N` sharti
/// (balans dinamikasi uchun), bo'sh bo'lsa butun tarix hisoblanadi.
String _balanceExpr({String dateBound = ''}) => '''
  a.initial_balance
  + COALESCE((SELECT SUM(t.amount) FROM transactions t
              WHERE t.account_id = a.id AND t.type = 'income'$dateBound), 0)
  - COALESCE((SELECT SUM(t.amount) FROM transactions t
              WHERE t.account_id = a.id AND t.type = 'expense'$dateBound), 0)
  - COALESCE((SELECT SUM(t.amount) FROM transactions t
              WHERE t.account_id = a.id AND t.type = 'transfer'$dateBound), 0)
  + COALESCE((SELECT SUM(CAST(ROUND(t.amount * COALESCE(t.transfer_rate, 1.0))
                              AS INTEGER))
              FROM transactions t
              WHERE t.to_account_id = a.id AND t.type = 'transfer'$dateBound), 0)
''';

/// Hisoblar + joriy qoldiq. Parametr `?1`: 1 — arxivlanganlar ham,
/// 0 — faqat faol hisoblar.
final String kAccountsWithBalanceSql = '''
SELECT a.*, ${_balanceExpr()} AS balance
FROM accounts a
WHERE (?1 = 1 OR a.is_archived = 0)
ORDER BY a.sort_order, a.id
''';

/// Bitta hisobning `?2` (unix seconds) sanasigacha bo'lgan qoldig'i.
/// Parametrlar: `?1` — account_id, `?2` — sana.
final String kAccountBalanceUntilSql = '''
SELECT ${_balanceExpr(dateBound: ' AND t.date_time <= ?2')} AS balance
FROM accounts a
WHERE a.id = ?1
''';

/// Umumiy balans (faqat `include_in_total` va arxivlanmaganlar),
/// `?1` (unix seconds) sanasigacha. Valyutalar bo'yicha guruhlangan.
final String kTotalBalanceByCurrencyUntilSql = '''
SELECT a.currency AS currency,
       SUM(${_balanceExpr(dateBound: ' AND t.date_time <= ?1')}) AS balance
FROM accounts a
WHERE a.is_archived = 0 AND a.include_in_total = 1
GROUP BY a.currency
''';
