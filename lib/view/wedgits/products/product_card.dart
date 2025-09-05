// ignore_for_file: unused_import

import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/controller/wishlist_controller.dart';
import 'package:babyshophub/models/product.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/products/productDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController = Get.find<WishlistController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 13 / 9,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            product.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Favorite Icon
                Positioned(
                  right: 8,
                  top: 8,
                  child: Obx(() {
                  final isFavorite = wishlistController.isInWishlist(product.id);
                  return IconButton(
                    onPressed: () {
                      wishlistController.toggleFavorite(product);
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey),
                    ),
                  );
                }),

                ),
                // Discount Badge
                if (product.oldPrice != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${calculateDiscount(product.price, product.oldPrice!)}% OFF',
                        style: AppTextStyle.withColor(
                          AppTextStyle.withWeight(AppTextStyle.bodySmall, FontWeight.bold),
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Info
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.withColor(
                      AppTextStyle.withWeight(AppTextStyle.h3, FontWeight.bold),
                      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.withWeight(AppTextStyle.bodyLarge, FontWeight.bold),
                          Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                        ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.oldPrice!.toStringAsFixed(2)}',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodySmall,
                            isDark ? Colors.grey[400]! : Colors.grey[600]!,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int calculateDiscount(double currentPrice, double oldPrice) {
    return (((oldPrice - currentPrice) / oldPrice) * 100).round();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }
}
