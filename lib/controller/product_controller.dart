import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:babyshophub/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductController extends GetxController {
  final RxList<Product> allProducts = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<Product> orderedProducts = <Product>[].obs;
  final RxSet<String> favoriteProductIds = <String>{}.obs;
  final RxList<String> categories = <String>[].obs;

  final RxInt selectedIndex = 0.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString searchQuery = ''.obs;
  RxList<Product> specialSaleProducts = <Product>[].obs;

  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  // ✅ Fetch all products
  Future<void> fetchProducts() async {
    try {
      final result = await supabase.from('products').select();

      final List<Product> fetched = (result as List)
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList();

      allProducts.assignAll(fetched);
      _generateCategories();
      applyFilters();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    }
  }

  // ✅ Fetch user's ordered products using FirebaseAuth UID
  Future<void> fetchOrderedProductsForCurrentUser() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final response = await supabase
          .from('order_items')
          .select('product_name')
          .eq('user_id', userId);

      final List<String> orderedNames = (response as List)
          .map((e) => e['product_name'] as String)
          .toList();

      if (allProducts.isEmpty) {
        await fetchProducts();
      }

      final matched = allProducts
          .where((product) => orderedNames.contains(product.name))
          .toList();

      orderedProducts.assignAll(matched);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Error', 'Failed to fetch ordered products: $e');
      });
      print('❌ Error fetching ordered products: $e');
    }
  }

  // ✅ Search and Category Filtering
  void applyFilters() {
    final category = selectedCategory.value;
    final query = searchQuery.value.toLowerCase();

    List<Product> result = category == 'All'
        ? allProducts.toList()
        : allProducts.where((p) => p.category == category).toList();

    if (query.isNotEmpty) {
      final matches = result
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
      final nonMatches = result
          .where((p) => !p.name.toLowerCase().contains(query))
          .toList();
      result = [...matches, ...nonMatches];
    }

    filteredProducts.assignAll(result);
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
    applyFilters();
  }

  void selectCategory(int index) {
    if (index < 0 || index >= categories.length) return;
    selectedIndex.value = index;
    selectedCategory.value = categories[index];
    applyFilters();
  }

  void setCategoryFilter(String category) {
    final index = categories.indexOf(category);
    if (index != -1) {
      selectedIndex.value = index;
      selectedCategory.value = category;
      applyFilters();
    }
  }

  // ✅ Favorites
  void toggleFavorite(String productId) {
    if (favoriteProductIds.contains(productId)) {
      favoriteProductIds.remove(productId);
    } else {
      favoriteProductIds.add(productId);
    }
  }

  // ✅ Add/Remove
  void addProduct(Product product) {
    allProducts.add(product);
    _generateCategories();
    applyFilters();
  }

  void removeProduct(String id) {
    allProducts.removeWhere((p) => p.id == id);
    _generateCategories();
    applyFilters();
  }

  void setOrderedProducts(List<Product> products) {
    orderedProducts.assignAll(products);
  }

  void clearOrderedProducts() {
    orderedProducts.clear();
  }

  // ✅ Auto-generate category list
  void _generateCategories() {
    final Set<String> unique = allProducts.map((p) => p.category).toSet();
    categories.assignAll(['All', ...unique.toList()..sort()]);
  }


void fetchSpecialSaleProducts() {
final specialProducts = allProducts.where((p) => p.isFortyPercentOff).toList();
  specialSaleProducts.assignAll(specialProducts);
}

  void applyAdvancedFilters({
    required String category,
    double? minPrice,
    double? maxPrice,
  }) {
    final query = searchQuery.value.toLowerCase();

    List<Product> results = allProducts;

    if (category != 'All') {
      results = results.where((product) => product.category == category).toList();
    }

    if (minPrice != null) {
      results = results.where((product) => product.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      results = results.where((product) => product.price <= maxPrice).toList();
    }

    if (query.isNotEmpty) {
      results = results
          .where((product) =>
              product.name.toLowerCase().contains(query) ||
              (product.description.toLowerCase()).contains(query))
          .toList();
    }

    filteredProducts.assignAll(results);
  }
}
