import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIcon(int codePoint) {
    // ignore: must_be_const
    return IconData(codePoint, fontFamily: 'MaterialIcons');
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
