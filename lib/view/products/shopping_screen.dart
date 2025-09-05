import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/models/product.dart';

class ShoppingScreen extends StatefulWidget {
  final String? filterCategory;
  final bool showOnlyOrdered;

  const ShoppingScreen({super.key, this.filterCategory, this.showOnlyOrdered = false});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final ProductController controller = Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  final TextEditingController _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      if (widget.showOnlyOrdered) {
        controller.fetchOrderedProductsForCurrentUser();
      } else {
        controller.fetchProducts();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final List<Product> productsToShow = widget.showOnlyOrdered
          ? controller.orderedProducts
          : controller.filteredProducts;

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.iconTheme.color),
          title: widget.showOnlyOrdered
              ? Text(
                  "My Orders",
                  style: AppTextStyle.withColor(AppTextStyle.h3, Theme.of(context).textTheme.bodyLarge!.color!),
                )
              : _buildSearchBar(theme),
        ),
        body: Column(
          children: [
            Expanded(
              child: productsToShow.isEmpty
                  ? Center(
                      child: Text(
                        'No products found',
                        style: AppTextStyle.withColor(AppTextStyle.h3, theme.hintColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: productsToShow.length,
                      itemBuilder: (context, index) {
                        final product = productsToShow[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 3,
                          color: theme.cardColor,
                          shadowColor: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: InkWell(
                            onTap: () {
                              // Optional: Navigate to product detail
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      product.imageUrl ?? '',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(
                                        Icons.image,
                                        size: 100,
                                        color: theme.iconTheme.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: AppTextStyle.withColor(
                                            AppTextStyle.h3,
                                           Theme.of(context).textTheme.bodyLarge!.color!
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Rs ${product.price.toStringAsFixed(0)}",
                                          style: AppTextStyle.withColor(
                                            AppTextStyle.bodyMedium,
                                            theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (product.category.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              product.category,
                                              style: AppTextStyle.withColor(
                                                AppTextStyle.bodySmall,
                                                Theme.of(context).textTheme.bodyLarge!.color!
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return TextField(
      controller: _searchController,
      onChanged: controller.setSearchQuery,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: "Search products...",
        hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: theme.iconTheme.color),
                onPressed: () {
                  _searchController.clear();
                  controller.setSearchQuery('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
