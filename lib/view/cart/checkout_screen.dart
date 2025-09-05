import 'package:babyshophub/controller/cart_controller.dart';
import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/models/address.dart';
import 'package:babyshophub/models/cart_item.dart';
import 'package:babyshophub/models/order.dart';
import 'package:babyshophub/repositories/address_repository.dart';
import 'package:babyshophub/repositories/order_repository.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/utils/order_num_generator.dart';
import 'package:babyshophub/view/cart/order_confirmation_screen.dart';
import 'package:babyshophub/view/wedgits/cart/address_card.dart';
import 'package:babyshophub/view/wedgits/cart/checkout_bottombar.dart';
import 'package:babyshophub/view/wedgits/cart/order_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutScreen({super.key, required this.cartItems, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final RxString selectedPaymentMethod = 'Cash on Delivery'.obs;
  final Rxn<Address> selectedAddress = Rxn<Address>();
  final AddressRepository addressRepository = AddressRepository();
  final OrderRepository orderRepository = OrderRepository();

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final addresses = await addressRepository.getAddresses();
    if (addresses.isEmpty) return;
    selectedAddress.value = addresses.firstWhere((addr) => addr.isDefault, orElse: () => addresses.first);
  }

  Future<void> _placeOrder() async {
    final address = selectedAddress.value;
    if (address == null) {
      Get.snackbar('Address Required', 'Please select a shipping address');
      return;
    }

    final orderNumber = await SupabaseOrderNumberGenerator.generate();

    final subtotal = widget.cartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    const double shippingFee = 10.0;
    const double taxRate = 0.05;
    final double tax = subtotal * taxRate;
    final double grandTotal = subtotal + tax + shippingFee;

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      await orderRepository.insertOrder(Order(
        orderNumber: orderNumber,
        itemCount: widget.cartItems.length,
        totalAmount: grandTotal,
        status: OrderStatus.active,
        imageUrl: widget.cartItems.first.product.imageUrl ?? '',
        orderDate: DateTime.now(),
        address: address.fullAddress,
        paymentMethod: selectedPaymentMethod.value,
      ));

      for (final item in widget.cartItems) {
        await orderRepository.insertOrderItem(
          orderNumber: orderNumber,
          productName: item.product.name,
          quantity: item.quantity,
          totalAmount: item.product.price * item.quantity,
          imageUrl: item.product.imageUrl ?? '',
          productPrice: item.product.price,
        );
      }

      final orderedProducts = widget.cartItems.map((e) => e.product).toList();
      Get.find<ProductController>().setOrderedProducts(orderedProducts);
      Get.find<CartController>().clearCart();

      Get.back();
      Get.snackbar('Success', 'Order placed successfully!');
      Get.offAll(() => OrderConfirmationScreen(
            orderNumber: orderNumber,
            totalAmount: grandTotal,
          ));
    } catch (e, stackTrace) {
      Get.back();
      Get.snackbar('Order Failed', 'Something went wrong');
      print('Order Error: $e');
      print('StackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
        ),
        title: Text('Checkout', style: AppTextStyle.withColor(AppTextStyle.h3, theme.textTheme.bodyLarge?.color ?? Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Shipping Address', _showAddressSelectionBottomSheet),
            const SizedBox(height: 16),
            Obx(() => selectedAddress.value == null
                ? Text('No address selected.', style: theme.textTheme.bodyMedium)
                : AddressCard(address: selectedAddress.value!, showChangeButton: false)),
            const SizedBox(height: 24),
            _buildSectionTitle('Payment Method'),
            const SizedBox(height: 16),
            _buildPaymentCard('Cash on Delivery'),
            const SizedBox(height: 24),
            _buildSectionTitle('Order Summary'),
            const SizedBox(height: 16),
            OrderSummaryCard(cartItems: widget.cartItems, totalAmount: widget.totalAmount),
          ],
        ),
      ),
      bottomNavigationBar: CheckoutBottomBar(
        totalAmount: widget.totalAmount,
        onPlaceOrder: _placeOrder,
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        TextButton(
          onPressed: onTap,
          child: Text('Change', style: TextStyle(color: theme.colorScheme.primary)),
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: AppTextStyle.withColor(AppTextStyle.h3, theme.textTheme.bodyLarge?.color ?? Colors.black),
    );
  }

  Widget _buildPaymentCard(String method) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.money, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Text(method, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  void _showAddressSelectionBottomSheet() async {
    final addresses = await addressRepository.getAddresses();
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose Shipping Address', style: AppTextStyle.h3),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            if (addresses.isEmpty)
              Text("No saved addresses.", style: theme.textTheme.bodyMedium)
            else
              ...addresses.map((addr) => GestureDetector(
                    onTap: () {
                      selectedAddress.value = addr;
                      Get.back();
                    },
                    child: AddressCard(address: addr, showChangeButton: false),
                  )),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
