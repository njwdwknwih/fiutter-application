import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshophub/models/order.dart';
import 'package:babyshophub/repositories/order_repository.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';

class OrderStatusManagement extends StatefulWidget {
  const OrderStatusManagement({super.key});

  @override
  State<OrderStatusManagement> createState() => _OrderStatusManagementState();
}

class _OrderStatusManagementState extends State<OrderStatusManagement> {
  final OrderRepository _orderRepo = OrderRepository();
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Order>> _ordersFuture;
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadOrders() {
    _ordersFuture = _orderRepo.getAllOrders().then((orders) {
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
      });
      return orders;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredOrders = _allOrders;
      } else {
        _filteredOrders = _allOrders
            .where((order) =>
                order.orderNumber.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _updateStatus(Order order, OrderStatus newStatus) async {
    final success =
        await _orderRepo.updateOrderStatus(order.orderNumber, newStatus);
    if (success) {
      Get.snackbar(
        'Success',
        'Order #${order.orderNumber} updated to ${newStatus.name.capitalizeFirst}',
        snackPosition: SnackPosition.BOTTOM,
      );
      _loadOrders();
    } else {
      Get.snackbar('Error', 'Failed to update status',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'Manage Order Status',
          style:
              AppTextStyle.withColor(AppTextStyle.h3, Theme.of(context).primaryColor),
        ),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading orders.'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Order Number',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _filteredOrders.isEmpty
                    ? const Center(child: Text('No matching orders found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Order #${order.orderNumber}', style: AppTextStyle.h3),
    const SizedBox(height: 8),

    Text(
      '${order.itemCount} items • \$${order.totalAmount.toStringAsFixed(2)}',
      style: AppTextStyle.bodyMedium,
    ),

    const SizedBox(height: 8),

    if (order.address != null && order.address!.isNotEmpty)
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address: ', style: AppTextStyle.bodyMedium),
          Expanded(
            child: Text(order.address!, style: AppTextStyle.bodySmall),
          ),
        ],
      ),

    if (order.paymentMethod != null && order.paymentMethod!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Row(
          children: [
            Text('Payment: ', style: AppTextStyle.bodyMedium),
            Text(order.paymentMethod!, style: AppTextStyle.bodySmall),
          ],
        ),
      ),

    const SizedBox(height: 12),

    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Status:', style: AppTextStyle.bodyMedium),
        DropdownButton<OrderStatus>(
          value: order.status,
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != order.status) {
              _updateStatus(order, newStatus);
            }
          },
          items: OrderStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.name),
            );
          }).toList(),
        ),
      ],
    ),
  ],
),

                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
