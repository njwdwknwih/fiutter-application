// ignore_for_file: unused_import

import 'package:babyshophub/view/products/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/models/product.dart';

class SpecialSaleScreen extends StatelessWidget {
  SpecialSaleScreen({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    controller.fetchSpecialSaleProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Special Sale - 40% OFF',
          style: AppTextStyle.withColor(
              AppTextStyle.h3, theme.textTheme.bodyLarge?.color ?? Colors.black),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Obx(() {
        if (controller.specialSaleProducts.isEmpty) {
          return Center(
            child: Text(
              "No 40% off products available.",
              style: AppTextStyle.bodyMedium,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.specialSaleProducts.length,
          itemBuilder: (context, index) {
            final product = controller.specialSaleProducts[index];

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
              margin: const EdgeInsets.only(bottom: 16),
              color: theme.cardColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Get.to(() => ProductDetailScreen(product: product)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl ?? '',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyle.withColor(
                                  AppTextStyle.h3, theme.colorScheme.onBackground),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  "Rs ${product.price.toStringAsFixed(0)}",
                                  style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge, theme.primaryColor),
                                ),
                                const SizedBox(width: 8),
                                if (product.oldPrice != null)
                                  Text(
                                    "Rs ${product.oldPrice!.toStringAsFixed(0)}",
                                    style: AppTextStyle.bodySmall.copyWith(
                                      color: isDark
                                          ? Colors.grey[500]
                                          : Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "40% OFF",
                                style: AppTextStyle.withColor(
                                    AppTextStyle.labelMedium, Colors.redAccent),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
