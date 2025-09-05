// ignore_for_file: unused_local_variable

import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/support/info_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/utils.dart';

class TermsOfServicesScreen extends StatelessWidget {
  const TermsOfServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: ()=>Get.back(),
        icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black,
        )),
        title: Text(
          'Terms of Services',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                title: 'Welcome to Baby Shop Hub',
                content:
                    'Welcome to Baby Shop Hub! By using our app, you agree to be bound by these Terms of Services. Please read them carefully before using the application.',
              ),
              InfoSection(
                title: 'Account Registration',
                content:
                    'To access certain features of the app, you may need to register for an account. You agree to provide accurate, complete, and current information. You are responsible for maintaining the confidentiality of your login credentials.',
              ),
              InfoSection(
                title: 'User Responsibilities',
                content:
                    'You agree to use the app only for lawful purposes. You must not use the app to transmit any harmful, offensive, or unlawful material or to violate the rights of others. Misuse of the app may result in suspension or termination of your account.',
              ),
              InfoSection(
                title: 'Privacy Policy',
                content:
                    'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and safeguard your personal data. By using the app, you consent to our data practices.',
              ),
              InfoSection(
                title: 'Payments & Transactions',
                content:
                    'All purchases made through the app are subject to our payment policies. We use secure third-party services to process payments. You are responsible for any charges incurred through your account.',
              ),
              InfoSection(
                title: 'Intellectual Property',
                content:
                    'All content, designs, logos, and other intellectual property on Baby Shop Hub are owned by us or our licensors. You may not copy, reproduce, or distribute any part of the app without prior written permission.',
              ),
              InfoSection(
                title: 'Termination',
                content:
                    'We reserve the right to suspend or terminate your access to the app at our sole discretion, without notice, for conduct that we believe violates these Terms or is harmful to other users or the app.',
              ),
                InfoSection(
                  title: 'Limitation of Liability',
                  content:
                      'Baby Shop Hub is provided "as is" and "as available". We do not guarantee that the app will always be available, uninterrupted, or error-free. We are not liable for any direct or indirect damages arising from your use of the app.',
                ),
              InfoSection(
                title: 'Changes to Terms',
                content:
                    'We may update these Terms of Services from time to time. Changes will be posted within the app, and continued use of the app means you accept the updated terms.',
              ),

                   const SizedBox(height: 24,),
              Text(
                'Last Updated: July 2025',
                style: AppTextStyle.withColor(
            AppTextStyle.bodySmall,
            isDark ? Colors.grey[400]! : Colors.grey[600]!,
          ),),
            ],
          ),
        ),
      ),
    );
  }
}