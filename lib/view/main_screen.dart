// ignore_for_file: use_super_parameters

import 'package:babyshophub/controller/navigation_controller.dart';
import 'package:babyshophub/view/user/account_screen.dart';
import 'package:babyshophub/view/home_screen.dart';
import 'package:babyshophub/view/products/shopping_screen.dart';
import 'package:babyshophub/view/wedgits/profile/custom_bottom_navbar.dart';
import 'package:babyshophub/view/wishList_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  final int initialTabIndex;

  const MainScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final NavigationController navigationController;

  @override
  void initState() {
    super.initState();
    navigationController = Get.put(NavigationController(), permanent: true);

    // Set the initial tab index once after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigationController.currentIndex.value != widget.initialTabIndex) {
        navigationController.setTabIndex(widget.initialTabIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: navigationController.currentIndex.value,
            children: [
              const HomeScreen(),
              const ShoppingScreen(showOnlyOrdered: true),
              WishListScreen(),
              const AccoutScreen(),
            ],
          )),
      bottomNavigationBar: const CustomBottomNavbar(),
    );
  }
}
