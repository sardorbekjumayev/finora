# Shaxsiy Moliya Tracker — Loyiha Rejasi

> Offline ishlaydigan, backend talab qilmaydigan, individual foydalanuvchi uchun Flutter mobil ilova.

---

## 1. Loyiha haqida qisqacha

**Maqsad:** Istalgan odam ilovani yuklab olib, o'z pulini nazorat qila olsin: qayerdan kirim bo'ldi, nimaga chiqim qilindi, hozir qancha naqd va kartada pul bor, oy davomida qanday o'zgarish bo'ldi — hammasi bitta joyda va **internetsiz**.

**Asosiy prinsiplar:**
- **Offline-first** — internet, login, server kerak emas.
- **Ma'lumot telefonda** — barcha data lokal bazada saqlanadi.
- **Maxfiylik** — hech narsa tashqariga chiqmaydi (ixtiyoriy backup foydalanuvchi qo'lida).
- **Tezlik** — yangi yozuv qo'shish maksimum 3–4 tap.
- **Aniqlik** — balans har doim tranzaksiyalardan hisoblanadi, "yolg'on" qoldiq bo'lmaydi.

**Maqsadli auditoriya:** talabalar, ishlaydigan yoshlar, oilaviy byudjetni yuritmoqchi bo'lganlar, kichik daromadni nazorat qilmoqchi bo'lgan har kim.

---

## 2. Texnologiyalar (Tech Stack)

| Qatlam | Tanlov | Izoh |
|---|---|---|
| Framework | Flutter (stable) + Dart 3 | Android + iOS |
| Lokal baza | **Drift** (SQLite ustida) | Type-safe, migratsiya, murakkab so'rovlar (statistika uchun juda muhim) |
| State management | **Riverpod** | Test qilish oson, Drift stream bilan yaxshi ishlaydi |
| Navigatsiya | **go_router** | |
| Grafiklar | **fl_chart** | Pie, bar, line |
| Lokalizatsiya | `flutter_localizations` + `intl` (ARB) | uz, ru, en |
| Sozlamalar | `shared_preferences` | Til, tema, valyuta, PIN holati |
| Xavfsizlik | `local_auth` + `flutter_secure_storage` | PIN / barmoq izi / Face ID |
| Bildirishnoma | `flutter_local_notifications` | Eslatmalar, takroriy to'lovlar |
| Fayllar | `path_provider`, `file_picker`, `share_plus` | Backup / export / import |
| Export | `csv`, `excel`, `pdf` (+ `printing`) | |
| Kod generatsiya | `freezed`, `json_serializable`, `build_runner` | |
| Test | `flutter_test`, `mocktail`, `integration_test` | |

> Muqobil: **Isar** yoki **ObjectBox**. Lekin moliyaviy hisob-kitob uchun relatsion baza (SQLite/Drift) ishonchliroq.

---

## 3. Arxitektura

**Clean-ish, feature-first** tuzilma:

```
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, theme, router
│   ├── router.dart
│   └── theme/
├── core/
│   ├── database/                # Drift: tables, DAOs, migrations
│   ├── utils/                   # money formatter, date helpers
│   ├── constants/
│   ├── widgets/                 # umumiy UI komponentlar
│   └── services/                # backup, notification, security
├── features/
│   ├── onboarding/
│   ├── accounts/                # hamyonlar (naqd, karta...)
│   ├── transactions/
│   ├── categories/
│   ├── budgets/
│   ├── goals/
│   ├── debts/
│   ├── recurring/
│   ├── statistics/
│   ├── search/
│   ├── backup/
│   └── settings/
└── l10n/
```

Har bir feature ichida: `data/` (DAO, repository), `domain/` (model, use-case), `presentation/` (screen, widget, provider).

**Muhim qaror — pul qanday saqlanadi:**
- Pul miqdori **`int`** (minor units, ya'ni tiyin = 1/100) sifatida saqlanadi. `double` **ishlatilmaydi** (yaxlitlash xatolari uchun).
- Ko'rsatishda `intl` NumberFormat orqali formatlanadi (`1 250 000 so'm`).

---

## 4. Ma'lumotlar modeli (Database Schema)

### `accounts` — hamyonlar / hisoblar
| Maydon | Tur | Izoh |
|---|---|---|
| id | int PK | |
| name | text | "Naqd", "Uzcard", "Humo", "Kapital" |
| type | enum | `cash`, `card`, `bank`, `savings`, `ewallet`, `other` |
| currency | text | `UZS`, `USD`, `EUR`, `RUB`... |
| initial_balance | int | Boshlang'ich qoldiq (onboardingda kiritiladi) |
| icon / color | text/int | |
| is_archived | bool | O'chirish o'rniga arxivlash |
| include_in_total | bool | Umumiy balansga qo'shilsinmi |
| sort_order | int | |
| created_at | datetime | |

### `categories`
| Maydon | Tur | Izoh |
|---|---|---|
| id | int PK | |
| name | text | |
| type | enum | `income` / `expense` |
| icon / color | | |
| parent_id | int? | Sub-kategoriya uchun |
| is_default | bool | |
| is_archived | bool | |

### `transactions`
| Maydon | Tur | Izoh |
|---|---|---|
| id | int PK | |
| type | enum | `income`, `expense`, `transfer` |
| amount | int | Doim musbat (minor units) |
| account_id | FK | Qaysi hisobdan/hisobga |
| to_account_id | FK? | Faqat `transfer` uchun |
| category_id | FK? | Transferda null |
| date_time | datetime | Foydalanuvchi tanlagan sana-vaqt |
| note | text? | Izoh |
| transfer_rate | real? | Valyutalar orasida o'tkazma kursi |
| recurring_id | FK? | Takroriy qoidadan kelgan bo'lsa |
| debt_id | FK? | Qarz bilan bog'liq bo'lsa |
| created_at / updated_at | datetime | |

### `tags` va `transaction_tags` (many-to-many)
Masalan: `#ish`, `#oila`, `#safar`.

### `budgets`
| Maydon | Izoh |
|---|---|
| id, category_id? (null = umumiy), amount, period (`monthly`/`weekly`), start_day, rollover (bool), alert_percent (masalan 80) |

### `goals` (jamg'arma maqsadlari)
| Maydon | Izoh |
|---|---|
| id, name, target_amount, saved_amount (hisoblanadi), target_date?, account_id?, icon, color |

### `goal_contributions`
Maqsadga qo'shilgan/olingan summalar (goal_id, amount, date, transaction_id?).

### `debts` (qarzlar)
| Maydon | Izoh |
|---|---|
| id, person_name, direction (`i_owe` / `owed_to_me`), total_amount, due_date?, note, status (`open`/`closed`) |

### `debt_payments`
Qarz bo'yicha qisman to'lovlar (debt_id, amount, date, account_id).

### `recurring_rules`
| Maydon | Izoh |
|---|---|
| id, type, amount, account_id, category_id, note, frequency (`daily`/`weekly`/`monthly`/`yearly`), interval, start_date, end_date?, next_run, auto_create (bool yoki "tasdiqlash so'rash") |

### `exchange_rates` (ixtiyoriy, qo'lda kiritiladi)
| base, target, rate, updated_at |

### `app_settings`
Kalit-qiymat (til, tema, asosiy valyuta, oyning boshlanish kuni, PIN holati...).

### Balans formulasi
```
account_balance = initial_balance
                + SUM(income where account_id = X)
                - SUM(expense where account_id = X)
                - SUM(transfer where account_id = X)          // chiqqan
                + SUM(transfer where to_account_id = X)       // kirgan
```
Balans **saqlanmaydi**, har safar hisoblanadi (yoki cache qilinadi va tranzaksiya o'zgarganda qayta hisoblanadi). Shunda tahrirlash/o'chirishda xato chiqmaydi.

---

## 5. Funksiyalar (Features)

### 5.1. Onboarding va boshlang'ich sozlash ⭐ (MVP)
1. Til tanlash (O'zbekcha / Русский / English).
2. Asosiy valyuta (UZS default).
3. **Boshlang'ich qoldiq kiritish:**
   - "Qo'lingizda qancha **naqd** pul bor?" → `Naqd` hisobi yaratiladi.
   - "Kartangizda qancha bor?" → karta nomi + summa (bir nechta karta qo'shish mumkin).
   - "Keyinroq qo'shaman" — o'tkazib yuborish.
4. Standart kategoriyalar avtomatik yaratiladi (tahrirlash mumkin).
5. Ixtiyoriy: PIN o'rnatish, kunlik eslatma yoqish.

### 5.2. Hisoblar (Accounts) ⭐ (MVP)
- Naqd, karta, bank hisobi, omonat, elektron hamyon — cheksiz qo'shish.
- Har birining nomi, ikonkasi, rangi, valyutasi.
- **Balansni to'g'rilash (Reconcile):** "Haqiqiy qoldiq boshqacha" → foydalanuvchi haqiqiy summani kiritadi, ilova farqni avtomatik "Tuzatish" tranzaksiyasi sifatida yozadi.
- Hisobni arxivlash (tarix saqlanadi).
- Umumiy balansga qo'shish/qo'shmaslik tugmasi.
- Hisoblar tartibini drag-drop bilan o'zgartirish.

### 5.3. Tranzaksiyalar ⭐ (MVP)
- **Uch tur:** Kirim, Chiqim, O'tkazma (naqd → karta, karta → karta).
- **Tez qo'shish:** katta raqamli klaviatura, summa → kategoriya → hisob → saqlash.
- Sana/vaqt tanlash (default: hozir), izoh, teglar.
- Tahrirlash, o'chirish (undo bilan — Snackbar "Bekor qilish").
- Nusxa ko'chirish ("shu chiqimni yana qo'shish").
- Ro'yxat: kunlar bo'yicha guruhlangan, har kun jami bilan.
- Swipe: chapga — o'chirish, o'ngga — tahrirlash.
- Summa maydonida oddiy kalkulyator (`12000+5000*2`).
- Ko'p valyutali o'tkazma (USD → UZS, kurs qo'lda kiritiladi).

### 5.4. Kategoriyalar ⭐ (MVP)
**Standart chiqim:** Oziq-ovqat, Transport, Uy-joy/Ijara, Kommunal, Aloqa/Internet, Kiyim, Sog'liq, Ta'lim, Ko'ngilochar, Restoran/Kafe, Sovg'alar, Oila, Obuna, Boshqa.
**Standart kirim:** Maosh, Stipendiya, Frilans, Sovg'a, Biznes, Investitsiya, Boshqa.

- Yangi kategoriya yaratish, ikonka va rang tanlash.
- Sub-kategoriyalar (v1.0).
- Arxivlash / birlashtirish (merge).
- Kategoriya o'chirilganda tranzaksiyalar "Kategoriyasiz"ga o'tadi yoki boshqa kategoriyaga ko'chiriladi.

### 5.5. Bosh sahifa (Dashboard) ⭐ (MVP)
- **Umumiy balans** (barcha hisoblar yig'indisi).
- Hisoblar kartochkalari: Naqd — X, Uzcard — Y...
- Joriy oy: kirim / chiqim / farq.
- Oxirgi 5–10 ta tranzaksiya.
- Byudjet holati (progress bar).
- Tezkor "+" tugmasi (kirim / chiqim / o'tkazma).
- Balansni yashirish (ko'z ikonkasi) — jamoat joyida foydali.

### 5.6. Statistika va Hisobotlar ⭐ (MVP + keyingi versiyalar)
**Davr filtri:** Bugun, Hafta, Oy, Yil, Maxsus oraliq; oldingi/keyingi davrga o'tish.

**Grafiklar:**
- Chiqimlar kategoriyalar bo'yicha — **Pie/Donut** (foiz va summa).
- Kirim vs Chiqim — **Bar chart** (kunlar/haftalar/oylar kesimida).
- Balans dinamikasi — **Line chart** (vaqt bo'yicha qoldiq o'zgarishi).
- Kategoriya ichiga kirish — shu kategoriyadagi barcha tranzaksiyalar.
- Hisoblar bo'yicha taqsimot.

**Raqamli ko'rsatkichlar:**
- Jami kirim, jami chiqim, sof natija (savings).
- O'rtacha kunlik chiqim.
- Eng katta chiqim/kirim.
- Eng ko'p pul ketayotgan kategoriya.
- Oldingi davr bilan solishtirish (↑12% / ↓5%).
- Jamg'arma foizi (savings rate).

**Qo'shimcha (v1.x):**
- Haftaning qaysi kunida ko'p xarajat qilinadi (heatmap).
- Oylik trend va prognoz ("shu sur'atda oy oxirida ~X so'm qoladi").
- Teglar bo'yicha statistika.

### 5.7. Byudjetlar (v1.0)
- Umumiy yoki kategoriya bo'yicha oylik/haftalik limit.
- Progress bar: sarflangan / limit.
- 80% va 100% da bildirishnoma.
- Rollover (qolgan summani keyingi oyga o'tkazish) — ixtiyoriy.

### 5.8. Jamg'arma maqsadlari (v1.0)
- "Telefon sotib olish — 5 000 000", "Safar — 10 000 000".
- Maqsadga pul qo'shish / olish.
- Progress va taxminiy yetib borish sanasi.
- Maqsadga erishilganda tabrik animatsiyasi 🎉.

### 5.9. Qarzlar (v1.0)
- "Men qarzdorman" va "Menga qarzdor" ro'yxati.
- Shaxs nomi, summa, muddat, izoh.
- Qisman to'lov qo'shish (bu tranzaksiya sifatida ham hisobdan o'tadi).
- Muddat yaqinlashganda eslatma.
- Umumiy: "Jami qarzim: X", "Menga qaytishi kerak: Y".

### 5.10. Takroriy tranzaksiyalar (v1.0)
- Har oy: ijara, internet, obuna, maosh.
- Chastota: kunlik / haftalik / oylik / yillik.
- Ikki rejim: avtomatik yozish yoki "Tasdiqlaysizmi?" bildirishnomasi.
- Ilova ochilmagan davrdagi o'tkazib yuborilgan takrorlar ilova ochilganda hisoblab qo'shiladi (offline uchun muhim!).

### 5.11. Qidiruv va Filtr (v1.0)
- Matn bo'yicha qidiruv (izoh, kategoriya).
- Filtr: tur, hisob, kategoriya, teg, summa oralig'i, sana oralig'i.
- Saralash: sana, summa.

### 5.12. Zaxira nusxa va Export (⭐ MVP'da asosiy backup)
- **Backup:** barcha bazani bitta faylga (`.json` yoki `.db`) eksport qilish → Telegram/Drive/Email orqali saqlash (`share_plus`).
- **Restore:** fayldan tiklash (telefon almashganda).
- **CSV / Excel export:** davr va filtr bo'yicha.
- **PDF hisobot:** oylik hisobot.
- Avto-backup eslatmasi ("Oxirgi backup 30 kun oldin").
- (Keyinroq, ixtiyoriy) Google Drive / iCloud sinxronizatsiya.

### 5.13. Xavfsizlik (v1.0)
- PIN kod (4–6 raqam).
- Biometrika (barmoq izi / Face ID).
- Ilova fonga o'tganda avto-qulf (sozlanadigan vaqt).
- Task switcher'da ekranni yashirish (screenshot himoyasi — ixtiyoriy).
- Balansni yashirish rejimi.

### 5.14. Bildirishnomalar (v1.0)
- Kunlik eslatma: "Bugungi xarajatlaringizni kiritdingizmi?" (vaqtni tanlash).
- Byudjet ogohlantirishlari.
- Qarz muddati.
- Takroriy to'lovlar.

### 5.15. Sozlamalar (⭐ MVP'da asosiylari)
- Til: uz / ru / en.
- Tema: Light / Dark / System.
- Asosiy valyuta va formatlash (ming ajratgich, kasr).
- Oyning boshlanish kuni (masalan maosh 5-sanada bo'lsa, oy 5-dan boshlansin).
- Haftaning boshlanish kuni (Dushanba/Yakshanba).
- Kategoriyalar, teglar, hisoblarni boshqarish.
- Barcha ma'lumotni o'chirish (ikki bosqichli tasdiq bilan).
- Ilova haqida, fikr-mulohaza.

### 5.16. Qo'shimcha g'oyalar (v2.0+)
- **Home screen widget** — "Tez chiqim qo'shish" va joriy balans.
- **Quick actions** (ikonkani uzoq bosganda: "+ Chiqim", "+ Kirim").
- **SMS parser (Android)** — bank SMS'idan avtomatik tranzaksiya yaratish (Uzcard/Humo xabarlari). Ruxsat talab qiladi, maxfiylik bilan ehtiyot bo'lish kerak.
- **Chek rasmi biriktirish** (kamera/galereya).
- **Ovozli kiritish** ("Bugun taksiga 15 ming sarfladim").
- **Oila rejimi** (backend kerak bo'ladi — hozirgi loyiha doirasidan tashqari).
- **Gamification:** ketma-ket kunlar (streak), yutuqlar.
- **Moliyaviy salomatlik ko'rsatkichi** (savings rate asosida ball).

---

## 6. Ekranlar ro'yxati va navigatsiya

**Bottom Navigation (4–5 ta):**
1. 🏠 **Bosh sahifa** — Dashboard
2. 📋 **Tranzaksiyalar** — to'liq tarix + qidiruv/filtr
3. ➕ **Qo'shish** (markazda FAB)
4. 📊 **Statistika**
5. ⚙️ **Yana / Sozlamalar** (Hisoblar, Byudjet, Maqsadlar, Qarzlar, Backup, Sozlamalar)

**Ekranlar:**
- Splash → Onboarding (til, valyuta, boshlang'ich balans)
- Dashboard
- Tranzaksiyalar ro'yxati / Filtr / Qidiruv
- Tranzaksiya qo'shish/tahrirlash (kirim/chiqim/o'tkazma tablari)
- Tranzaksiya tafsilotlari
- Hisoblar ro'yxati / Hisob tafsilotlari / Hisob qo'shish / Balansni to'g'rilash
- Kategoriyalar ro'yxati / Kategoriya tahrirlash
- Statistika (Umumiy / Kategoriyalar / Trend / Hisoblar)
- Byudjetlar ro'yxati / Byudjet qo'shish
- Maqsadlar ro'yxati / Maqsad tafsilotlari
- Qarzlar ro'yxati / Qarz tafsilotlari
- Takroriy to'lovlar
- Backup / Restore / Export
- Xavfsizlik (PIN o'rnatish, biometrika)
- Sozlamalar
- Qulf ekrani (PIN/Biometrika)

---

## 7. UX / UI tamoyillari

- **Material 3** dizayn, moslashuvchan Light/Dark tema.
- Kirim — yashil, Chiqim — qizil, O'tkazma — ko'k (rang-ko'r foydalanuvchilar uchun ikonka va ishora (+/−) ham bo'lsin).
- Katta, o'qilishi oson raqamlar; ming ajratgichli format (`1 250 000`).
- Bo'sh holatlar (empty states) uchun do'stona illyustratsiya va "Birinchi tranzaksiyani qo'shing" tugmasi.
- Har bir muhim harakatda haptic feedback va silliq animatsiya.
- Qo'l bilan bir qo'lda ishlatish qulayligi: asosiy tugmalar ekranning pastki yarmida.
- Accessibility: katta shrift qo'llab-quvvatlash, Semantics label'lar.
- Tezlik: ilova ochilganda <1 soniyada dashboard ko'rinishi.

---

## 8. Muhim chekka holatlar (Edge cases)

- Tranzaksiya tahrirlanganda/o'chirilganda balans qayta to'g'ri hisoblanishi.
- Hisob o'chirilmoqchi bo'lsa va unda tranzaksiyalar bo'lsa → arxivlash taklif qilinadi.
- Manfiy balans (karta minusga ketsa) — ogohlantirish, lekin ruxsat berish.
- Turli valyutadagi hisoblar orasida o'tkazma va umumiy balansni asosiy valyutaga o'girish.
- Vaqt zonasi/sana o'zgarishi, yoz-qish vaqti.
- Katta ma'lumot hajmi (10 000+ tranzaksiya) — pagination va indekslar (`date_time`, `account_id`, `category_id`).
- Baza migratsiyasi: ilova yangilanganda eski foydalanuvchi ma'lumoti yo'qolmasligi (Drift schema versioning + testlar).
- Backup fayl versiyasi mos kelmasa — tushunarli xato xabari.
- Ilova uzoq vaqt ochilmasa takroriy tranzaksiyalarni to'g'ri "yetkazib qo'yish".
- Telefon qayta ishga tushganda/ilova o'chirilganda bildirishnomalar qayta rejalashtirilishi.
- Foydalanuvchi ilovani o'chirib tashlasa data yo'qoladi — shuning uchun backup eslatmasi **juda muhim**.

---

## 9. Bosqichma-bosqich reja (Roadmap)

### 🟢 Bosqich 0 — Tayyorgarlik (2–3 kun)
- Flutter loyiha yaratish, papka tuzilmasi, linter (`very_good_analysis` yoki `flutter_lints`).
- Drift, Riverpod, go_router sozlash.
- Tema (Light/Dark), umumiy widgetlar.
- Figma/qog'ozda asosiy ekranlar eskizi.

### 🟢 Bosqich 1 — MVP (2–3 hafta)
- Baza sxemasi va DAO'lar (accounts, categories, transactions).
- Onboarding + boshlang'ich qoldiq (naqd/karta).
- Hisoblar CRUD.
- Kategoriyalar (standart + o'z kategoriya).
- Tranzaksiya qo'shish/tahrirlash/o'chirish (kirim, chiqim, o'tkazma).
- Dashboard (umumiy balans, hisoblar, oylik kirim/chiqim, oxirgi tranzaksiyalar).
- Tranzaksiyalar ro'yxati (kunlar bo'yicha guruh).
- Asosiy statistika: pie (kategoriya) + kirim/chiqim bar chart + davr filtri.
- Til (uz/en/ru) va tema.
- Oddiy backup/restore (fayl).
- ✅ **Natija:** kundalik ishlatsa bo'ladigan to'liq offline ilova.

### 🟡 Bosqich 2 — v1.0 (2–3 hafta)
- Qidiruv va filtrlar, teglar.
- Byudjetlar + bildirishnomalar.
- Jamg'arma maqsadlari.
- Qarzlar moduli.
- Takroriy tranzaksiyalar.
- PIN + biometrika.
- Balansni to'g'rilash (reconcile).
- CSV/Excel export.
- Kunlik eslatma.
- Kengaytirilgan statistika (trend, solishtirish, o'rtacha kunlik).

### 🟠 Bosqich 3 — Sayqallash va Release (1–2 hafta)
- Unit va widget testlar (ayniqsa balans hisoblash, migratsiya, takroriy mantiq).
- Performance profiling.
- Ikonka, splash, store skrinshotlari, tavsif (uz/ru/en).
- Privacy Policy sahifasi ("Ma'lumot faqat qurilmada saqlanadi").
- Beta test (do'stlar, guruhdoshlar) → fikr-mulohaza.
- Google Play (va xohlansa App Store) ga chiqarish.

### 🔵 Bosqich 4 — v2.0 (kelajak)
- Home widget, quick actions.
- PDF hisobotlar.
- Chek rasmi biriktirish.
- Android SMS parser.
- Ixtiyoriy bulutli backup (Google Drive).
- Ovozli kiritish.

---

## 10. Test rejasi

| Tur | Nimani qamrab oladi |
|---|---|
| **Unit** | Balans formulasi, pul formatlash, takroriy qoida hisoblash, byudjet foizi, statistika agregatsiyasi |
| **Database** | Drift in-memory baza bilan DAO testlar, migratsiya testlari |
| **Widget** | Tranzaksiya qo'shish formasi, kalkulyator klaviatura, dashboard |
| **Integration** | Onboarding → tranzaksiya qo'shish → statistikada ko'rinishi → backup → restore |
| **Qo'lda** | Turli ekran o'lchamlari, katta shrift, dark mode, sekin/eski telefonlar |

---

## 11. Release va kuzatuv

- Android: App Bundle (`.aab`), Play Console, versiyalash (`1.0.0+1`).
- iOS (ixtiyoriy): Apple Developer akkaunti kerak.
- Crash hisoboti: Firebase Crashlytics (internet bo'lganda, ixtiyoriy) yoki umuman yo'q — maxfiylik uchun foydalanuvchiga tanlov berish.
- Analytics: minimal yoki umuman yo'q ("hech narsa yig'maymiz" — marketing ustunligi).
- Foydalanuvchi fikri: ilova ichida "Fikr bildirish" (Telegram/email havola).

---

## 12. Xavflar va yechimlar

| Xavf | Yechim |
|---|---|
| Foydalanuvchi telefonini yo'qotsa/almashtirsa data ketadi | Backup eslatmalari, oson restore, kelajakda bulutli backup |
| Balans hisoblashda xato | Pulni `int` saqlash, balans faqat tranzaksiyalardan hisoblanadi, testlar |
| Baza o'zgarganda (yangi versiya) ma'lumot buzilishi | Drift migratsiyalari + avtomatik pre-migration backup |
| Ilova murakkab bo'lib ketishi | Avval MVP, so'ng bosqichma-bosqich |
| Foydalanuvchi kiritishni unutishi | Eslatma, tez qo'shish, widget |

---

## 13. MVP uchun qisqa checklist

- [ ] Loyiha sozlash (Drift, Riverpod, go_router, l10n)
- [ ] DB: accounts, categories, transactions
- [ ] Onboarding: til, valyuta, naqd va karta boshlang'ich qoldig'i
- [ ] Hisoblar CRUD
- [ ] Kategoriyalar (standart + custom)
- [ ] Kirim / Chiqim / O'tkazma qo'shish va tahrirlash
- [ ] Dashboard: umumiy balans, hisoblar, oylik xulosa
- [ ] Tranzaksiyalar ro'yxati
- [ ] Statistika: pie + bar + davr filtri
- [ ] Dark/Light tema
- [ ] Backup/Restore
- [ ] Testlar (balans, migratsiya)

---

*Eslatma: bu reja o'zgarishi mumkin — avval MVP'ni chiqarib, haqiqiy foydalanuvchilar fikriga qarab keyingi funksiyalarni tartiblash tavsiya etiladi.*
