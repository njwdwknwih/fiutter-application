import 'package:babyshophub/admin/admin_panel.dart';
import 'package:babyshophub/controller/product_controller.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/forget_pass_screen.dart';
import 'package:babyshophub/view/main_screen.dart';
import 'package:babyshophub/view/auth/signup_screen.dart';
import 'package:babyshophub/view/wedgits/common/costomTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String error = '';

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      // Sign in with Firebase
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailcontroller.text.trim(),
              password: _passwordcontroller.text.trim());

      final User? user = credential.user;

      if (user != null) {
        // Register or find the ProductController
        final ProductController productController =
            Get.isRegistered<ProductController>()
                ? Get.find<ProductController>()
                : Get.put(ProductController());

        // Fetch data
        await productController.fetchProducts();
        await productController.fetchOrderedProductsForCurrentUser();

        // Fetch role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection("users")
            .where("email", isEqualTo: user.email)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final role = userDoc.docs.first['role'];

          if (role == 'a') {
            Get.offAll(() => const AdminMainScreen());
          } else {
            Get.offAll(() => const MainScreen());
          }
        } else {
          setState(() {
            error = 'User role not found.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Authentication failed.';
      });
    } catch (e) {
      setState(() {
        error = 'Unexpected error occurred.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue shopping',
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
                  controller: _emailcontroller,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Password',
                  prefixIcons: Icons.fingerprint,
                  keyBoardType: TextInputType.visiblePassword,
                  controller: _passwordcontroller,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                    child: Text(
                      'Forget Password?',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign In',
                            style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const SignUpScreen()),
                      child: Text(
                        'Sign Up',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
