// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'package:babyshophub/models/order.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/support/feed_back.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

    final ImageProvider<Object> imageProvider =
        (order.imageUrl != null && order.imageUrl!.startsWith('http'))
            ? NetworkImage(order.imageUrl!)
            : const AssetImage('assets/images/placeholder.png');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.itemCount} items · ${currencyFormat.format(order.totalAmount)}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusChip(context, order.status.name),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (order.status == OrderStatus.delivered) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            InkWell(
              onTap: () => Get.to(() => FeedbackScreen()),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Give Feedback',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String statusName) {
    final status = statusName.toLowerCase();

    Color getStatusColor() {
      switch (status) {
        case 'active':
          return Colors.blue;
        case 'pending':
          return Colors.orange;
        case 'delivered':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: AppTextStyle.withColor(
          AppTextStyle.bodySmall,
          getStatusColor(),
        ),
      ),
    );
  }
}
