// ignore_for_file: unused_local_variable

import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/support/info_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize =MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(),
         icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black,
         )),
        title: Text(
          'Privacy Policy',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InfoSection(
  title: 'Information We Collect',
  content:
      'We collect personal information you provide directly to us when creating an account, placing an order, or contacting support. This includes your name, email address, phone number, delivery address, and payment information.',
),
InfoSection(
  title: 'How We Use Your Information',
  content:
      'We use your information to process orders, manage your account, provide customer support, send updates or promotions, and improve your user experience. We may also use data for analytics and service enhancement.',
),
InfoSection(
  title: 'Information Sharing',
  content:
      'We do not sell or rent your personal data to third parties. We may share information with trusted third-party providers (such as payment gateways and shipping services) only to perform essential services on our behalf.',
),
InfoSection(
  title: 'Data Security',
  content:
      'We implement security measures such as encryption, secure servers, and authentication procedures to protect your information. While we strive to use commercially acceptable means to protect your data, no method is 100% secure.',
),
InfoSection(
  title: 'Your Rights',
  content:
      'You have the right to access, update, or delete your personal data. You can manage your account details through the app or request data removal by contacting our support team.',
),
InfoSection(
  title: 'Cookie Policy',
  content:
      'We use cookies and similar technologies to enhance app functionality and analyze usage patterns. You can control cookie settings through your device preferences or browser settings.',
),

                const SizedBox(height: 24,),
                Text(
                  'Last Updated: July 2025',
                  style: AppTextStyle.withColor(
              AppTextStyle.bodySmall,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
              )
            ],
          ),
        ),
      ),
    );
  }
}