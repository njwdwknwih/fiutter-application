// ignore_for_file: unnecessary_cast, unnecessary_null_comparison

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderController extends GetxController {
  final RxList<Map<String, dynamic>> orders = <Map<String, dynamic>>[].obs;

  Future<void> fetchUserOrders() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      print(' User not authenticated');
      return;
    }

    try {
      final response = await supabase
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('order_date', ascending: false); 
      if (response == null || response.isEmpty) {
        orders.clear();
        print('No orders found.');
      } else {
        orders.assignAll(response as List<Map<String, dynamic>>);
        print('Orders loaded: ${orders.length}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }
}
