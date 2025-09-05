enum OrderStatus { active, pending, delivered, cancelled }

class Order {
  final String orderNumber;
  final double totalAmount;
  final OrderStatus status;
  final String? imageUrl;
  final DateTime orderDate;
  final int itemCount;
  final String? address;          // ✅ new
  final String? paymentMethod;  

  Order({
    required this.orderNumber,
    required this.totalAmount,
    required this.status,
    this.imageUrl,
    required this.orderDate,
    required this.itemCount,
    this.address,
    this.paymentMethod,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderNumber: map['order_number'],
      totalAmount: (map['product_price'] as num).toDouble(),
      status: _statusFromString(map['product_status']),
      imageUrl: map['image_url'],
      orderDate: DateTime.parse(map['order_date']),
      itemCount: map['item_count'] ?? 0,
      address: map['user_address'],
      paymentMethod: map['payment_method'],
    );
  }

  static String statusToString(OrderStatus status) {
    return status.name;
  }

  static OrderStatus _statusFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'active':
        return OrderStatus.active;
      default:
        return OrderStatus.active; 
    }
  }
}
