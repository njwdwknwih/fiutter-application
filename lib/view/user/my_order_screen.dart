// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:babyshophub/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshophub/models/order.dart';
import 'package:babyshophub/repositories/order_repository.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/cart/order_card.dart';

class MyOrderScreen extends StatefulWidget {
  MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen>
    with SingleTickerProviderStateMixin {
  final OrderRepository _repository = OrderRepository();
  late TabController _tabController;
  final Map<OrderStatus, Future<List<Order>>> _orderFutures = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _preloadOrders();
  }

  void _preloadOrders() {
    for (var status in OrderStatus.values) {
      _orderFutures[status] = _repository.getOrdersByStatus(status);
    }
  }

  Future<void> _refreshOrders(OrderStatus status) async {
    final refreshed = await _repository.getOrdersByStatus(status);
    setState(() {
      _orderFutures[status] = Future.value(refreshed);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.to(()=>MainScreen()),
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'My Orders',
          style: AppTextStyle.withColor(
              AppTextStyle.h3, isDark ? Colors.white : Colors.black),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor:
              isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Pending'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(OrderStatus.active),
          _buildOrderList(OrderStatus.pending),
          _buildOrderList(OrderStatus.delivered),
          _buildOrderList(OrderStatus.cancelled),
        ],
      ),
    );
  }

  Widget _buildOrderList(OrderStatus status) {
    return RefreshIndicator(
      onRefresh: () => _refreshOrders(status),
      child: FutureBuilder<List<Order>>(
        future: _orderFutures[status],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading ${_capitalize(status.name)} orders',
                style: AppTextStyle.bodyMedium,
              ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Text(
                'No ${_capitalize(status.name)} orders found.',
                style: AppTextStyle.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
              );
            },
          );
        },
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
