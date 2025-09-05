// ignore_for_file: unused_element_parameter, unused_import

import 'package:babyshophub/admin/admin_custom_drawer.dart';
import 'package:babyshophub/admin/inventory.dart';
import 'package:babyshophub/admin/productmanagement/order_status_management.dart';
import 'package:babyshophub/admin/user_management.dart';
import 'package:babyshophub/controller/theme_controller.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Panel',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          GetBuilder<ThemeController>(
            builder: (controller) => IconButton(
              icon: Icon(controller.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: controller.toggleTheme,
            ),
          ),
        ],
      ),
      drawer: const AdminCustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Overview',
              style: AppTextStyle.withColor(
                AppTextStyle.h2,
                isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // ✅ Total Users (Firestore)
            _buildUserSummaryBox(
              context: context,
              title: 'Total Users',
              icon: Icons.people_outline,
              color: Colors.blue,
              onTap: () => Get.to(() => const UserManagement()),
            ),

            const SizedBox(height: 16),

            // ✅ Total Products (Supabase)
            _buildSupabaseSummaryBox(
              context: context,
              title: 'Total Products',
              icon: Icons.shopping_bag_outlined,
              table: 'products',
              color: Colors.purple,
              onTap: () => Get.to(()=>Inventory()),
            ),

            const SizedBox(height: 16),

            // ✅ Total Orders (Supabase)
            _buildSupabaseSummaryBox(
              context: context,
              title: 'Total Orders',
              icon: Icons.receipt_long_outlined,
              table: 'orders',
              color: Colors.deepOrange,
              onTap: () => Get.to(()=>OrderStatusManagement()),
            ),

            const SizedBox(height: 16),

            // ✅ Total Revenue (Sum of order_items)
            _buildTotalOrderAmountBox(
              context: context,
              title: 'Total Revenue',
              icon: Icons.attach_money,
              color: Colors.green,
              onTap: () => Get.snackbar('Revenue', 'Tapped on Total Revenue'),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Total Users from Firestore
  Widget _buildUserSummaryBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'u')
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _buildSummaryCard(context, title, icon, '$count', color, onTap: onTap);
      },
    );
  }

  /// ✅ Summary Count from Supabase (Products / Orders)
  Widget _buildSupabaseSummaryBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String table,
    required Color color,
    VoidCallback? onTap,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client.from(table).select(),
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.length : 0;
        return _buildSummaryCard(context, title, icon, '$count', color, onTap: onTap);
      },
    );
  }

  /// ✅ Total Revenue = SUM(product_price * quantity)
  Widget _buildTotalOrderAmountBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client.from('order_items').select('product_price, quantity'),
      builder: (context, snapshot) {
        double total = 0.0;
        if (snapshot.hasData) {
          for (var item in snapshot.data!) {
            final price = item['product_price'];
            final quantity = item['quantity'];
            if (price is num && quantity is num) {
              total += price * quantity;
            }
          }
        }

        return _buildSummaryCard(
          context,
          title,
          icon,
          '\$${total.toStringAsFixed(2)}',
          color,
          onTap: onTap,
        );
      },
    );
  }

  /// ✅ Reusable Tappable Summary Card
  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    IconData icon,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[700]!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyle.withColor(AppTextStyle.h3, color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
