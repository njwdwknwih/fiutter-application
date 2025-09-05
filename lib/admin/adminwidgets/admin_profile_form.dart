import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/common/costomTextField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool showPasswordFields = false;
  bool isLoading = true;
  bool isSaving = false;
  String email = '';
  String passwordError = '';

  final RegExp passwordLength = RegExp(r'^.{8,}$');
  final RegExp passwordUppercase = RegExp(r'[A-Z]');
  final RegExp passwordDigits = RegExp(r'(?:.*\d.*){2,}');
  final RegExp passwordSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = auth.currentUser;
    if (user == null) return;

    final snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final userData = snapshot.docs.first.data();
      nameController.text = userData['fullName'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      email = userData['email'] ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveProfileChanges() async {
    final user = auth.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      // Update name and phone in Firestore
      final snapshot = await firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final docId = snapshot.docs.first.id;
        await firestore.collection('users').doc(docId).update({
          'fullName': nameController.text.trim(),
          'phone': phoneController.text.trim(),
        });
      }

      // Handle password update if shown
      if (showPasswordFields) {
        final current = currentPasswordController.text.trim();
        final newPass = newPasswordController.text.trim();

        if (current.isEmpty || newPass.isEmpty) {
          Get.snackbar("Error", "Please enter both current and new password");
          setState(() => isSaving = false);
          return;
        }

        // Validation check
        if (!passwordUppercase.hasMatch(newPass)) {
          passwordError = 'Must contain at least one uppercase letter';
        } else if (!passwordDigits.hasMatch(newPass)) {
          passwordError = 'Must contain at least 2 digits';
        } else if (!passwordLength.hasMatch(newPass)) {
          passwordError = 'Must be at least 8 characters';
        } else if (!passwordSpecial.hasMatch(newPass)) {
          passwordError = 'Must contain a special character';
        } else {
          passwordError = '';
        }

        if (passwordError.isNotEmpty) {
          setState(() => isSaving = false);
          return;
        }

        try {
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: current,
          );
          await user.reauthenticateWithCredential(cred);
          await user.updatePassword(newPass);

          // Clear password fields
          currentPasswordController.clear();
          newPasswordController.clear();
          showPasswordFields = false;

          Get.snackbar("Success", "Profile updated successfully");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'wrong-password') {
            Get.snackbar("Error", "Current password is incorrect");
          } else if (e.code == 'requires-recent-login') {
            Get.snackbar("Error", "Please log in again to update password.");
          } else {
            Get.snackbar("Error", "Password update failed: ${e.message}");
          }
          setState(() => isSaving = false);
          return;
        }
      } else {
        Get.snackbar("Success", "Profile updated successfully");
      }

    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShadowedField(
            context,
            CustomTextField(
              label: 'Full Name',
              prefixIcons: Icons.person_outline,
              controller: nameController,
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildShadowedField(
            context,
            CustomTextField(
              label: 'Email',
              prefixIcons: Icons.mail_outline,
              intialValue: email,
              keyBoardType: TextInputType.emailAddress,
              readOnly: true,
            ),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildShadowedField(
            context,
            CustomTextField(
              label: 'Phone Number',
              prefixIcons: Icons.phone_outlined,
              controller: phoneController,
              keyBoardType: TextInputType.phone,
            ),
            isDark,
          ),

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  showPasswordFields = !showPasswordFields;
                });
              },
              child: Text(
                showPasswordFields ? 'Cancel' : 'Change Password',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),

          if (showPasswordFields) ...[
            const SizedBox(height: 8),
            _buildShadowedField(
              context,
              CustomTextField(
                label: 'Current Password',
                prefixIcons: Icons.lock_outline,
                controller: currentPasswordController,
                isPassword: true,
              ),
              isDark,
            ),
            const SizedBox(height: 16),
            _buildShadowedField(
              context,
              CustomTextField(
                label: 'New Password',
                prefixIcons: Icons.lock_reset_outlined,
                keyBoardType: TextInputType.visiblePassword,
                isPassword: true,
                controller: newPasswordController,
                onChanged: (value) {
                  setState(() {
                    passwordError = '';
                    if (value.isEmpty) {
                      passwordError = 'Please enter a password';
                    } else if (!passwordUppercase.hasMatch(value)) {
                      passwordError = 'Must contain at least one uppercase letter';
                    } else if (!passwordDigits.hasMatch(value)) {
                      passwordError = 'Must contain at least 2 digits';
                    } else if (!passwordLength.hasMatch(value)) {
                      passwordError = 'Must be at least 8 characters';
                    } else if (!passwordSpecial.hasMatch(value)) {
                      passwordError = 'Must contain a special character';
                    }
                  });
                },
              ),
              isDark,
            ),
            if (passwordError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(passwordError, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveProfileChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Save Changes',
                      style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildShadowedField(BuildContext context, Widget child, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
