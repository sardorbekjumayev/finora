import 'package:flutter/material.dart';

/// Ilovada **emoji / stiker ishlatilmaydi** — faqat Material ikonkalar.
/// Bazada ikonka `iconKey` matni sifatida saqlanadi, bu yerda `IconData`ga
/// moslashtiriladi. Shunda yangi ikonka qo'shilsa ham eski data buzilmaydi.
class AppIcons {
  const AppIcons._();

  static const IconData fallback = Icons.category_outlined;

  /// Kategoriya va hisoblar uchun ikonka katalogi.
  static const Map<String, IconData> catalog = {
    // --- Chiqim ---
    'restaurant': Icons.restaurant_outlined,
    'grocery': Icons.local_grocery_store_outlined,
    'transport': Icons.directions_bus_outlined,
    'taxi': Icons.local_taxi_outlined,
    'fuel': Icons.local_gas_station_outlined,
    'home': Icons.home_outlined,
    'utilities': Icons.bolt_outlined,
    'water': Icons.water_drop_outlined,
    'internet': Icons.wifi_outlined,
    'phone': Icons.smartphone_outlined,
    'clothes': Icons.checkroom_outlined,
    'health': Icons.favorite_outline,
    'pharmacy': Icons.medical_services_outlined,
    'education': Icons.school_outlined,
    'entertainment': Icons.sports_esports_outlined,
    'movie': Icons.movie_outlined,
    'sport': Icons.fitness_center_outlined,
    'gift': Icons.card_giftcard_outlined,
    'family': Icons.people_outline,
    'child': Icons.child_care_outlined,
    'pet': Icons.pets_outlined,
    'beauty': Icons.content_cut_outlined,
    'subscription': Icons.subscriptions_outlined,
    'travel': Icons.flight_outlined,
    'hotel': Icons.hotel_outlined,
    'repair': Icons.build_outlined,
    'tax': Icons.receipt_long_outlined,
    'charity': Icons.volunteer_activism_outlined,
    'coffee': Icons.local_cafe_outlined,
    'shopping': Icons.shopping_bag_outlined,
    'book': Icons.menu_book_outlined,
    'computer': Icons.computer_outlined,

    // --- Kirim ---
    'salary': Icons.payments_outlined,
    'scholarship': Icons.workspace_premium_outlined,
    'freelance': Icons.laptop_mac_outlined,
    'business': Icons.storefront_outlined,
    'investment': Icons.trending_up_outlined,
    'rent_income': Icons.key_outlined,
    'bonus': Icons.star_outline,
    'refund': Icons.replay_outlined,

    // --- Hisoblar ---
    'wallet': Icons.account_balance_wallet_outlined,
    'cash': Icons.payments_outlined,
    'card': Icons.credit_card_outlined,
    'bank': Icons.account_balance_outlined,
    'savings': Icons.savings_outlined,
    'ewallet': Icons.phone_android_outlined,
    'safe': Icons.lock_outline,

    // --- Umumiy ---
    'other': Icons.more_horiz_outlined,
    'category': Icons.category_outlined,
    'flag': Icons.flag_outlined,
    'target': Icons.adjust_outlined,
    'debt': Icons.handshake_outlined,
    'calendar': Icons.event_repeat_outlined,
  };

  static IconData resolve(String? key) => catalog[key] ?? fallback;

  static List<String> get keys => catalog.keys.toList(growable: false);

  /// Hisob turi uchun standart ikonka.
  static String defaultIconForAccountType(String typeName) {
    switch (typeName) {
      case 'cash':
        return 'cash';
      case 'card':
        return 'card';
      case 'bank':
        return 'bank';
      case 'savings':
        return 'savings';
      case 'ewallet':
        return 'ewallet';
      default:
        return 'wallet';
    }
  }
}
