import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/support/contact_support_section.dart';
import 'package:babyshophub/view/wedgits/support/help_categories_section.dart';
import 'package:babyshophub/view/wedgits/support/popular_question_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark =  Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: ()=> Get.back(),
          icon: Icon(Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black,)
          ),
        title: Text(
          'Help Center',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context,isDark),
            const SizedBox(height: 24,),
            PopularQuestionSection(),
              const SizedBox(height: 24,),
              const HelpCategoriesSection(),
              const SizedBox(height: 24,),
              const ContactSupportSection(),
          ],
        ),
      ),
    );
  }
  Widget _buildSearchBar(BuildContext context,bool isDark){
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ?
            Colors.black.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2)
          )
        ]
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Seacrh for help',
          hintStyle: AppTextStyle.withColor(
            AppTextStyle.bodyMedium,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled:  true,
          fillColor: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}