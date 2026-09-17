import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(int codePoint) {
    switch (codePoint) {
      case 58746:
        return Icons.fastfood;
      case 58673:
        return Icons.directions_bus;
      case 59105:
        return Icons.shopping_cart;
      case 58914:
        return Icons.movie;
      case 58683:
        return Icons.medical_services;
      case 57895:
        return Icons.work;
      case 58941:
        return Icons.trending_up;
      case 0xE8B0:
        return Icons.account_balance_wallet;
      case 0xE84F:
        return Icons.account_balance;
      default:
        for (final icon in availableIcons) {
          if (icon.codePoint == codePoint) return icon;
        }
        return Icons.help_outline;
    }
  }

  // A list of common icons for custom categories
  static final List<IconData> availableIcons = [
    Icons.fastfood,
    Icons.directions_bus,
    Icons.shopping_cart,
    Icons.movie,
    Icons.medical_services,
    Icons.school,
    Icons.home,
    Icons.shopping_bag,
    Icons.payments,
    Icons.work,
    Icons.card_giftcard,
    Icons.savings,
    Icons.restaurant,
    Icons.flight,
    Icons.fitness_center,
    Icons.pets,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.phone_android,
    Icons.wifi,
  ];
}
