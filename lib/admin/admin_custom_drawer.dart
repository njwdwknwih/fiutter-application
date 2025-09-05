// ignore_for_file: deprecated_member_use, unused_import

import 'package:babyshophub/admin/admin_edit_profile.dart';
import 'package:babyshophub/admin/fetch_user_feedback.dart';
import 'package:babyshophub/admin/productmanagement/add_product_screen.dart';
import 'package:babyshophub/admin/user_management.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/signin_screen.dart';
import 'package:babyshophub/view/profile/setting_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminCustomDrawer extends StatefulWidget {
  const AdminCustomDrawer({super.key});

  @override
  State<AdminCustomDrawer> createState() => _AdminCustomDrawerState();
}

class _AdminCustomDrawerState extends State<AdminCustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Drawer(
      backgroundColor: isDark ? Colors.black : Colors.white,
      child: Column(
        children: [
          // Header with Firestore data
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

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _drawerItem(
                  icon: Icons.home_outlined,
                  label: "Dashboard",
                  onTap: () => Navigator.pop(context),
                  iconColor: isDark ? Colors.white : Colors.black87,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
                _drawerItem(
                  icon: Icons.add_box_outlined,
                  label: "Add Product",
                  onTap: () {
                    Get.to(()=>AddProductScreen());
                  }, // Navigate to Add Product screen
                  iconColor: isDark ? Colors.white : Colors.black87,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
                _drawerItem(
                  icon: Icons.people_alt_outlined,
                  label: "Manage User",
                  onTap: () => Get.to(() => UserManagement()),
                  iconColor: isDark ? Colors.white : Colors.black87,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
                _drawerItem(
                  icon: Icons.feedback_outlined,
                  label: "Users Feedback",
                  onTap: () => Get.to(() => const FetchUserFeedback()),
                  iconColor: isDark ? Colors.white : Colors.black87,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
                _drawerItem(
                  icon: Icons.edit_outlined,
                  label: "Edit Profile",
                  onTap: () => Get.to(() => const AdminEditProfile()),
                  iconColor: isDark ? Colors.white : Colors.black87,
                  textColor: isDark ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
  Divider(height: 2,color: Colors.grey,),
  SizedBox(height: 2,),
          // Logout button pinned at bottom
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _drawerItem(
              icon: Icons.logout_outlined,
              label: "Logout",
              onTap: () => _showLogoutDialog(context),
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color iconColor,
    required Color textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label, style: TextStyle(fontSize: 16, color: textColor)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Logout',
                      style: AppTextStyle.withColor(AppTextStyle.bodyMedium, Colors.white),
                    ),
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
