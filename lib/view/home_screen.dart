// ignore_for_file: unused_import

import 'package:babyshophub/controller/theme_controller.dart';
import 'package:babyshophub/view/cart/cart_screen.dart';
import 'package:babyshophub/view/notification_screen.dart';
import 'package:babyshophub/view/products/all_products_screen.dart';
import 'package:babyshophub/view/wedgits/cetegory/category_chips.dart';
import 'package:babyshophub/view/wedgits/products/product_grid.dart';
import 'package:babyshophub/view/wedgits/profile/custom_drawer.dart';
import 'package:babyshophub/view/wedgits/common/sale_banner.dart';
import 'package:babyshophub/view/wedgits/search/custom_seachbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer:  CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).iconTheme.color,
        ),
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .where('email', isEqualTo: currentUser?.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (snapshot.hasError || snapshot.data!.docs.isEmpty) {
              return const Text('No User');
            }

            final userData = snapshot.data!.docs.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${userData['fullName'].toString().toUpperCase()}',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 101, 101, 101),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            );
          },
        ),
        actions: [
          // IconButton(
          //   onPressed: () => Get.to(() =>  NotificationScreen()),
          //   icon: const Icon(Icons.notifications_none_outlined),
          // ),
          IconButton(
            onPressed: () => Get.to(() => const CartScreen()),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          GetBuilder<ThemeController>(
            builder: (controller) => IconButton(
              icon: Icon(controller.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode),
              onPressed: controller.toggleTheme,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const CustomSearchBar(),
          const CategoryChips(),
          const SaleBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Our Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => const AllProductsScreen()),
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
          ),
          const Expanded(child: ProductGridScreen()),
        ],
      ),
    );
  }
}
