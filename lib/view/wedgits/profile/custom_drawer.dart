import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/signin_screen.dart';
import 'package:babyshophub/view/products/shopping_screen.dart';
import 'package:babyshophub/view/profile/edit_profile_screen.dart';
import 'package:babyshophub/view/profile/setting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class CustomDrawer extends StatelessWidget {
  final ProductController productController = Get.find<ProductController>();

  CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.white,
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where('email', isEqualTo: currentUser?.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const DrawerHeader(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final user = snapshot.data!.docs.first;

              return UserAccountsDrawerHeader(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Theme.of(context).primaryColor, const Color(0xFF825AC8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  currentAccountPicture: CircleAvatar(
    radius: 30,
    backgroundColor: Colors.white,
    backgroundImage: user.data().containsKey('profile_img') &&
            user['profile_img'] != null &&
            user['profile_img'].toString().isNotEmpty
        ? NetworkImage(user['profile_img'])
        : const AssetImage('assets/images/profile.jpg') as ImageProvider,
    child: user.data().containsKey('profile_img') &&
            user['profile_img'] != null &&
            user['profile_img'].toString().isNotEmpty
        ? null
        : const Icon(Icons.person, color: Colors.grey, size: 40),
  ),
  accountName: Text(
    user['fullName'].toString().toUpperCase(),
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  accountEmail: Text(user['email']),
);

            },
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _drawerItem(Icons.home_outlined, "Home", () => Navigator.pop(context), isDark),
                _drawerItem(Icons.person_outline, "My Profile", () =>Get.to(()=>EditProfileScreen()), isDark),
                _buildCategoryExpansion(context),
                const Divider(thickness: 0.5),
                _drawerItem(Icons.settings_outlined, "Settings", () =>Get.to(()=>const SettingsScreen()), isDark),
                _drawerItem(Icons.logout, "Logout", () => _showLogoutDialog(context), isDark, red: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap, bool isDark, {bool red = false}) {
    final color = red ? Colors.red : isDark ? Colors.white : Colors.black87;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(fontSize: 16, color: color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildCategoryExpansion(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

    return Obx(() {
      final categories = productController.categories;

      if (categories.isEmpty) return const SizedBox();

      return ExpansionTile(
        leading: Icon(Icons.apps_outlined, color: textColor),
        title: Text("Categories", style: TextStyle(fontSize: 16, color: textColor)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.only(left: 40),
        children: categories.map((c) => _categoryTile(c, textColor)).toList(),
      );
    });
  }

  Widget _categoryTile(String title, Color textColor) {
    return ListTile(
      title: Text(title, style: TextStyle(color: textColor)),
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      onTap: () {
        Get.back();
        Future.delayed(const Duration(milliseconds: 200), () {
          Get.to(() => ShoppingScreen(filterCategory: title));
        });
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.logout_rounded, color: Theme.of(context).primaryColor, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to logout?',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                       onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Get.offAll(()=>SignInScreen()) ;
                        },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Logout', style: AppTextStyle.withColor(AppTextStyle.bodyMedium, Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
