class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String? imageUrl;
  final String description;
  final bool isFavorite; 

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    required this.description,
    this.isFavorite = false,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['pid'].toString(),
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      oldPrice: map['old_price'] != null ? (map['old_price']).toDouble() : null,
      description: map['description'] ?? '',
      imageUrl: map['image_url'],
      isFavorite: map['is_favorite'] ?? false,
    );
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? oldPrice,
    String? imageUrl,
    String? description,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  double get discountPercent {
  if (oldPrice != null && oldPrice! > price) {
    return ((oldPrice! - price) / oldPrice!) * 100;
  }
  return 0;
}

bool get isFortyPercentOff => discountPercent.round() == 40;

}
