import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class UserDetailScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserDetailScreen({super.key, required this.userData});

  Future<List<Map<String, dynamic>>> _fetchUserOrders(String userId) async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('order_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    final date = DateTime.tryParse(dateString);
    return date != null ? DateFormat('dd MMM yyyy').format(date) : 'Invalid';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final userId = userData['id'] ?? '';
    final fullName = userData['fullName'] ?? 'N/A';
    final email = userData['email'] ?? 'N/A';
    final phone = userData['phone'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'User Details',
          style: AppTextStyle.withColor(AppTextStyle.h3, theme.primaryColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $fullName',
                style: AppTextStyle.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[800])),
            Text('Email: $email',
                style: AppTextStyle.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[800])),
            Text('Phone: $phone',
                style: AppTextStyle.bodyMedium.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[800])),
            const SizedBox(height: 16),
            const Divider(),
             Text('ORDERS:',
                style: AppTextStyle.withColor(
                  AppTextStyle.h3,
                  Theme.of(context).primaryColor
                )),
            const SizedBox(height: 10),
            Expanded(
              child: userId.isEmpty
                  ? const Center(child: Text("No UID found for user."))
                  : FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchUserOrders(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No orders found.'));
                        }

                        final orders = snapshot.data!;
                        return ListView.separated(
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            final imageUrl = order['image_url'] ?? '';

                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              leading: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.image_not_supported),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      child: Icon(Icons.shopping_bag),
                                    ),
                              title: Text(
                                'Order #${order['order_number'] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                  'Total: \$${order['product_price'] ?? '0.00'} | Status: ${order['product_status']}'),
                              trailing: Text(
                                _formatDate(order['order_date']?.toString()),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
