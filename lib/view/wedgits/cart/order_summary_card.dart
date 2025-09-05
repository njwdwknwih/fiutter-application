// lib/view/widgets/cart/order_summary_card.dart
import 'package:babyshophub/models/cart_item.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:flutter/material.dart';

class OrderSummaryCard extends StatelessWidget {
  final List<CartItem> cartItems;
  final double totalAmount;
  final double shippingFee;
  final double taxRate;

  const OrderSummaryCard({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    this.shippingFee = 10.0,
    this.taxRate = 0.05, // 5% tax
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    final taxAmount = subtotal * taxRate;
    final grandTotal = subtotal + shippingFee + taxAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            'Subtotal',
            '\$${subtotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Shipping',
            '\$${shippingFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            context,
            'Tax (${(taxRate * 100).toStringAsFixed(0)}%)',
            '\$${taxAmount.toStringAsFixed(2)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow(
            context,
            'Total',
            '\$${grandTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final textStyle = isTotal ? AppTextStyle.h3 : AppTextStyle.bodyLarge;
    final color = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyle.withColor(textStyle, color),
        ),
        Text(
          value,
          style: AppTextStyle.withColor(textStyle, color),
        ),
      ],
    );
  }
}
