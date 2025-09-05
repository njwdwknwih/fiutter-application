// product_services.dart
// ignore_for_file: unnecessary_type_check, unnecessary_cast

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:babyshophub/models/product.dart';

class ProductService {
  final supabase = Supabase.instance.client;
Future<List<Product>> fetchProducts() async {
  final response = await supabase
      .from('products')
      .select('*');

  final data = response; // for supabase-flutter v0.x
  // final data = response.data; // for newer versions, if .data exists

  if (data is List) {
    return data.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
  } else {
    throw Exception('Unexpected data format from Supabase');
  }
}

}
