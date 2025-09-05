// ignore_for_file: unused_local_variable, unused_import, deprecated_member_use

import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/signin_screen.dart';
import 'package:babyshophub/view/profile/edit_profile_screen.dart';
import 'package:babyshophub/view/support/help_center_screen.dart';
import 'package:babyshophub/view/user/my_order_screen.dart';
import 'package:babyshophub/view/profile/setting_screen.dart';
import 'package:babyshophub/view/shipping_address_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';


class AccoutScreen extends StatefulWidget {
  const AccoutScreen({super.key});

  @override
  State<AccoutScreen> createState() => _AccoutScreenState();
}

class _AccoutScreenState extends State<AccoutScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Screen",
        style: AppTextStyle.withColor(
          AppTextStyle.h3,
          isDark ? Colors.white : Colors.black
        ),
        ),
        actions: [
          IconButton(
            onPressed:()=> Get.to(()=> SettingsScreen()) , 
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            )
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24,),
            _buildMenuSection(context),
            
          ],
        ),
      ),
    );
  }
  Widget _buildProfileSection(BuildContext context){
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final User? currentUser = FirebaseAuth.instance.currentUser;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] :Colors.grey[100],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          ),
          child:StreamBuilder(
            stream:FirebaseFirestore.instance
            .collection("users")
            .where('email',isEqualTo: currentUser?.email)
            .snapshots() , 
            builder: (context, snapshot) {
               if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError || snapshot.data!.docs.isEmpty) {
                        return const Text('No User Data Found!');
                      }

                      final userData = snapshot.data!.docs.first;
              return Column(
                children: [
                  CircleAvatar(
  radius: 50,
  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
  backgroundImage: userData['profile_img'] != null && userData['profile_img'].toString().isNotEmpty
      ? NetworkImage(userData['profile_img'])
      : null,
  child: userData['profile_img'] == null || userData['profile_img'].toString().isEmpty
      ? Icon(
          Icons.person,
          size: 50,
          color: isDark ? Colors.white : Colors.black,
        )
      : null,
),

                  const SizedBox(height: 16,),
                  Text(
                   userData['fullName'].toString().toUpperCase(),
                   style: AppTextStyle.withColor(
                    AppTextStyle.h2,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                   ), 
                  ),
                  const SizedBox(height: 4,),
                  Text(
                   userData['email'],
                   style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                   ), 
                  ),
                   const SizedBox(height: 16,),
                   OutlinedButton(
                    onPressed: () => Get.to(()=>EditProfileScreen()), 
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32 ,vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )
                    ),
                    child: Text(
                      'Edit Profile',
                       style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                     Theme.of(context).textTheme.bodyLarge!.color!,
                   ), 
                    )
                   )
                ],
              );
            },
            )
        );
  }

  Widget _buildMenuSection(BuildContext context){
    final isDark = Theme.of(context).brightness ==Brightness.dark;
    final menuItems = [
      {'icon' : Icons.shopping_bag_outlined,'title':'My Orders'},
      {'icon' : Icons.location_on_outlined,'title':'Shipping Address'},
      {'icon' : Icons.help_outline,'title':'Help Center'},
      {'icon' : Icons.logout_outlined,'title':'Logout'}
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item){
               return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
  color: Theme.of(context).cardColor,
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.grey.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 4),
    )
  ],
),

                child: ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    item['title'] as String,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onTap: (){
                    if (item['title'] == 'Logout') {
                      _showLogoutDialog(context);
                    }else if(item['title'] == 'My Orders'){
                      Get.to(() => MyOrderScreen());
                    }else if(item['title'] == 'Shipping Address'){
                      Get.to(() => ShippingAddressScreen());
                    }else if(item['title'] == 'Help Center'){
                      Get.to(()=> HelpCenterScreen());
                    }
                  },
                ),
               ); 
        }).toList(),
      ),
      );
  }
  void _showLogoutDialog(BuildContext context){
        final isDark = Theme.of(context).brightness ==Brightness.dark;
        Get.dialog(
          AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24,vertical: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 8,),
                Text(
                  'Are you sure you want to logout?',
                  style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!
                    ),
                ),
                const SizedBox(height: 8,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: ()=> Get.back(), 
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        child: Text(
                          'Cencel',
                         style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                     Theme.of(context).textTheme.bodyLarge!.color!,
                    ), 
                        )
                        ),
                    ),
                    const SizedBox(width: 16,),
                    Expanded(
                      child: ElevatedButton(
                       onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Get.offAll(()=>SignInScreen()) ;
                        },
                        style:ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        child: Text(
                          'Logout',
                         style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Colors.white
                    ), 
                        )
                        ),
                    ),
                  ],
                )
              ],
            ),
          )
        );
  }
}