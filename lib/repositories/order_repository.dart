// ignore_for_file: unnecessary_null_comparison

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:babyshophub/models/order.dart';

class OrderRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> insertOrder(Order order) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

await _client.from('orders').insert({
  'order_number': order.orderNumber,
  'product_price': order.totalAmount,
  'product_status': Order.statusToString(order.status),
  'image_url': order.imageUrl ?? '',
  'order_date': order.orderDate.toIso8601String(),
  'item_count': order.itemCount,
  'user_id': userId,
  'user_address': order.address ?? '',
  'payment_method': order.paymentMethod ?? '',

});

      print('Order inserted: ${order.orderNumber}');
    } catch (e) {
      print('Error inserting order: $e');
      rethrow;
    }
  }

  Future<void> insertOrderItem({
    required String orderNumber,
    required String productName,
    required double productPrice,
    required int quantity,
    required double totalAmount,
    required String imageUrl,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      await _client.from('order_items').insert({
        'order_number': orderNumber,
        'product_name': productName,
        'product_price': productPrice,
        'quantity': quantity,
        'total_amount': totalAmount,
        'image_url': imageUrl,
        'user_id': userId,
      });

      print('Order item inserted: $productName');
    } catch (e) {
      print('Error inserting order item: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not authenticated");

      final response = await _client
          .from('orders')
          .select()
          .eq('product_status', status.name)
          .eq('user_id', userId)
          .order('order_date', ascending: false);

      return (response as List)
          .map((orderData) => Order.fromMap(orderData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching orders by status: $e');
      rethrow;
    }
  }

  /// Admin: Get all orders
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .order('order_date', ascending: false);

      return (response as List)
          .map((orderData) => Order.fromMap(orderData as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching all orders: $e');
      rethrow;
    }
  }

  Future<bool> updateOrderStatus(String orderNumber, OrderStatus newStatus) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User not authenticated");

      final trimmedOrderNumber = orderNumber.trim();
      print('Trying to update order_number: "$trimmedOrderNumber"');

      // Fetch current status
      final existing = await _client
          .from('orders')
          .select('product_status')
          .eq('order_number', trimmedOrderNumber)
          .maybeSingle();

      if (existing == null) {
        throw Exception('Order not found');
      }

      final currentStatus = existing['product_status'];
      print('Current status: $currentStatus');

      if (currentStatus == newStatus.name) {
        print('Status already "$currentStatus", skipping update.');
        return true;
      }

      final updateResponse = await _client
          .from('orders')
          .update({'product_status': newStatus.name})
          .eq('order_number', trimmedOrderNumber);

      print('Update response: $updateResponse');
      return true;
    } catch (e) {
      print('Failed to update status: $e');
      return false;
    }
  }
}
