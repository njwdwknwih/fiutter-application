import 'package:babyshophub/controller/cart_controller.dart';
import 'package:babyshophub/models/product.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/cart/checkout_screen.dart';
import 'package:babyshophub/view/wedgits/common/size_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final CartController cartController = Get.find();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'Details',
          style: AppTextStyle.withColor(AppTextStyle.h3, isDark ? Colors.white : Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareProduct(context, product.name, product.description),
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Favorite Icon
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                      ? Image.network(
                          product.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, size: 40),
                        ),
                ),
              
              ],
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTextStyle.withColor(
                            AppTextStyle.h2,
                            Theme.of(context).textTheme.headlineSmall?.color ?? Colors.black,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).textTheme.headlineMedium?.color ?? Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Category
                  Text(
                    product.category,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Size Selector
          if (product.category.toLowerCase() == 'clothing') ...[
  Text(
    'Select Size',
    style: AppTextStyle.withColor(
      AppTextStyle.labelMedium,
      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
    ),
  ),
  const SizedBox(height: 8),
  const SizeSelector(),
  SizedBox(height: screenHeight * 0.03),
],

                  SizedBox(height: screenHeight * 0.03),

                  // Description
                  Text(
                    'Description',
                    style: AppTextStyle.withColor(
                      AppTextStyle.labelMedium,
                      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Buttons
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              // Add to Cart
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    cartController.addToCart(product);
                    Get.snackbar('Success','Product ${product.name} added to cart');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    side: BorderSide(color: isDark ? Colors.white70 : Colors.black12),
                  ),
                  child: Text(
                    'Add To Cart',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),

              // Buy Now
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    cartController.addToCart(product);

                    // Navigate to CheckoutScreen with current cart
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Get.to(() => CheckoutScreen(
                            cartItems: cartController.cartItems.toList(),
                            totalAmount: cartController.totalPrice,
                          ));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Buy Now',
                    style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareProduct(BuildContext context, String name, String description) async {
    final box = context.findRenderObject() as RenderBox?;
    const String link = 'https://babiesshop.com/product/babycart';
    final String message = '$name\n\n$description\n\nShop now at $link';

    try {
      await Share.share(
        message,
        subject: name,
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : Rect.zero,
      );
    } catch (e) {
      // ✅ Display fallback snackbar
      Get.snackbar(
        'Error',
        'Unable to share product',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
