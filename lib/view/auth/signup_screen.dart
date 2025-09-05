// ignore_for_file: avoid_print

import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/auth/signin_screen.dart';
import 'package:babyshophub/view/wedgits/common/costomTextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namecontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();

  bool isLoading = false;
  String error = '';

  String nameError = '';
  String emailError = '';
  String passwordError = '';

  final RegExp emailRegex = RegExp(r'^[\w-\.]+@(gmail\.com|yahoo\.com|[\w-]+\.(pk|uk))$');
  final RegExp passwordLength = RegExp(r'^.{8,}$');
  final RegExp passwordUppercase = RegExp(r'^[A-Z]');
  final RegExp passwordDigits = RegExp(r'(?:.*\d.*){2,}');
  final RegExp passwordSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );

      _addUser(
        _namecontroller.text.trim(),
        _emailcontroller.text.trim(),
        _passwordcontroller.text.trim(),
      );

      Get.offAll(() => const SignInScreen());
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'Something went wrong.';
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

  void _addUser(String fullName, String email, String password) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance.collection("users").doc(currentUser.uid).set({
        'fullName': fullName,
        'email': email,
        'password': password,
        'role': "u",
        'phone': "N/A",
        'profile_img': "",
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      print("No user is currently signed in.");
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
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: AppTextStyle.withColor(AppTextStyle.h1, Theme.of(context).textTheme.bodyLarge!.color!),
                ),
                const SizedBox(height: 8),
                Text(
                  'Signup to get started',
                  style: AppTextStyle.withColor(AppTextStyle.bodyLarge, isDark ? Colors.grey[400]! : Colors.grey[600]!),
                ),
                const SizedBox(height: 40),

                /// Full Name
                CustomTextField(
                  label: 'Full Name',
                  prefixIcons: Icons.person_outlined,
                  keyBoardType: TextInputType.name,
                  controller: _namecontroller,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        nameError = 'Please enter your name';
                      } else if (!RegExp(r'^[A-Z][a-zA-Z ]+$').hasMatch(value)) {
                        nameError = 'Must start with uppercase and only letters';
                      } else {
                        nameError = '';
                      }
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),
                if (nameError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(nameError, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                const SizedBox(height: 16),

                /// Email
                CustomTextField(
                  label: 'Email',
                  prefixIcons: Icons.email_outlined,
                  keyBoardType: TextInputType.emailAddress,
                  controller: _emailcontroller,
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
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your email';
                    if (!emailRegex.hasMatch(value)) return 'Invalid email format';
                    return null;
                  },
                ),
                if (emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(emailError, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                const SizedBox(height: 16),

                /// Password
                CustomTextField(
                  label: 'Password',
                  prefixIcons: Icons.lock_outline,
                  keyBoardType: TextInputType.visiblePassword,
                  isPassword: true,
                  controller: _passwordcontroller,
                  onChanged: (value) {
                    setState(() {
                      passwordError = '';
                      if (value.isEmpty) {
                        passwordError = 'Please enter a password';
                      } else if (!passwordUppercase.hasMatch(value)) {
                        passwordError = 'Must start with an uppercase letter';
                      } else if (!passwordDigits.hasMatch(value)) {
                        passwordError = 'Must contain at least 2 digits';
                      } else if (!passwordLength.hasMatch(value)) {
                        passwordError = 'Must be at least 8 characters';
                      } else if (!passwordSpecial.hasMatch(value)) {
                        passwordError = 'Must contain a special character';
                      }
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) return 'Please enter your password';
                    if (!passwordUppercase.hasMatch(value)) return 'Must start with an uppercase letter';
                    if (!passwordDigits.hasMatch(value)) return 'At least 2 numbers required';
                    if (!passwordLength.hasMatch(value)) return 'Minimum 8 characters';
                    if (!passwordSpecial.hasMatch(value)) return 'At least 1 special character required';
                    return null;
                  },
                ),
                if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12),
                    child: Text(passwordError, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),

                const SizedBox(height: 16),

                /// Confirm Password
                CustomTextField(
                  label: 'Confirm Password',
                  prefixIcons: Icons.lock_outline,
                  keyBoardType: TextInputType.visiblePassword,
                  controller: _confirmpasswordcontroller,
                  isPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) return 'Please confirm your password';
                    if (value != _passwordcontroller.text) return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                if (error.isNotEmpty)
                  Text(error, style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Sign Up', style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: AppTextStyle.withColor(AppTextStyle.bodyMedium, isDark ? Colors.grey[400]! : Colors.grey[600]!)),
                    TextButton(
                      onPressed: () => Get.off(() => const SignInScreen()),
                      child: Text('Sign In', style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Theme.of(context).primaryColor)),
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
