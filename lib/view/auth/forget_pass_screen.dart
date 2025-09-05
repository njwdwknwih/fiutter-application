import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/common/costomTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String emailError = '';

  final RegExp emailRegex =
      RegExp(r'^[\w-\.]+@(gmail\.com|yahoo\.com|[\w-]+\.(pk|uk))$');

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    setState(() {
      emailError = '';
    });

    if (email.isEmpty) {
      setState(() {
        emailError = 'Please enter an email';
      });
      return;
    } else if (!email.contains('@')) {
      setState(() {
        emailError = 'Email must include @';
      });
      return;
    } else if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailError =
            'Email must end with gmail.com, yahoo.com, .pk or .uk';
      });
      return;
    }

    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      emailController.clear();

      Get.snackbar(
        'Email Sent',
        'Password reset instructions have been sent to $email',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Error',
        e.message ?? 'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red.shade600,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Get.until((route) => route.isFirst),
                  icon: const Icon(Icons.arrow_back_ios),
                  color: isDark ? Colors.white : Colors.black,
                ),
                const SizedBox(height: 20),
                Text(
                  'Reset Password',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email to reset password',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  label: 'Email',
                  prefixIcons: Icons.email_outlined,
                  keyBoardType: TextInputType.emailAddress,
                  controller: emailController,
                 onChanged: (value) {
                    setState(() {
                      emailError = '';
                      if (value.isEmpty) {
                        emailError = 'Please enter an email';
                      } else if (!value.contains('@')) {
                        emailError = 'Email must include @';
                      } else if (!emailRegex.hasMatch(value)) {
                        emailError = 'Email must end with gmail.com, yahoo.com, .pk or .uk';
                      }
                    });
                  },
                ),
                if (emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(
                      emailError,
                      style: const TextStyle(
                          color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: sendResetEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Send Mail',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
