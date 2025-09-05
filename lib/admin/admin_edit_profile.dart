import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/profile/profile_form.dart';
import 'package:babyshophub/view/wedgits/profile/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';


class AdminEditProfile extends StatelessWidget {
  const AdminEditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: ()=> Get.back(), 
          icon: Icon(Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black,
          )),
        title: Text(
          'Edit Profile',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24,),
            ProfileImageUploader(),
            SizedBox(height: 32,),
            ProfileForm()
          ],
        ),
      ),
    );
  }
}