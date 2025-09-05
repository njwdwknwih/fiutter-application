import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:flutter/material.dart';

class CheckoutBottomBar extends StatelessWidget {
  final double totalAmount;
  final VoidCallback onPlaceOrder;

  const CheckoutBottomBar({
    super.key,
    required this.totalAmount,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: ElevatedButton(
          onPressed: onPlaceOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Place Order (\$${totalAmount.toStringAsFixed(2)})',
            style: AppTextStyle.withColor(
              AppTextStyle.buttonMedium,
              Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
