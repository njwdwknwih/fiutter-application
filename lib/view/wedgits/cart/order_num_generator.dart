import 'package:shared_preferences/shared_preferences.dart';

class OrderNumberGenerator {
  static const String _key = 'order_number_counter';

  /// Generates a unique, incrementing order number starting from 1000.
  static Future<String> generateOrderNumber() async {
    final prefs = await SharedPreferences.getInstance();

    int current = prefs.getInt(_key) ?? 999; // Start from 999 → first = 1000
    int next = current + 1;

    await prefs.setInt(_key, next);

    return '$next';
  }
}
