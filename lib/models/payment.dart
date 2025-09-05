class PaymentMethod {
  final String id;
  final String type;
  final String last4Digits;
  final bool isDefault;

  PaymentMethod({
    required this.id, 
    required this.type, 
    required this.last4Digits, 
    required this.isDefault
    });
}
