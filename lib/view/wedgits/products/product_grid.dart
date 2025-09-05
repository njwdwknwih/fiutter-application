// lib/view/wedgits/products/product_grid.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/product_controller.dart';
import 'product_card.dart';

class ProductGridScreen extends StatelessWidget {
  const ProductGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductController>();

    return Obx(() {
      final products = controller.filteredProducts;

      if (products.isEmpty) {
        return const Center(
          child: Text(
            "No products found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
  itemBuilder: (context, index) {
  final product = controller.filteredProducts[index];
  return ProductCard(product: product); 
},

        ),
      );
    });
  }
}
