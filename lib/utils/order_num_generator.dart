import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseOrderNumberGenerator {
  static Future<String> generate() async {
    final client = Supabase.instance.client;

    try {
      final result = await client.rpc('increment_order_counter', params: {});
      return result.toString(); // This is the counter value like "1002"
    } catch (e) {
      throw Exception('Failed to generate order number: $e');
    }
  }
}
