import 'package:babyshophub/admin/user_detail.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        userRole = null;
        isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: user.email)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        setState(() {
          userRole = userDoc.docs.first['role'];
          isLoading = false;
        });
      } else {
        setState(() {
          userRole = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        userRole = null;
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      Get.snackbar('Deleted', 'User successfully deleted.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void viewUser(Map<String, dynamic> userData) {
    Get.to(() => UserDetailScreen(userData: userData));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black),
        ),
        title: Text("User Management",
            style: AppTextStyle.withColor(
                AppTextStyle.h3, Theme.of(context).primaryColor)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "u")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final userData = userDoc.data() as Map<String, dynamic>;

              final Map<String, dynamic> userWithId = {
                ...userData,
                'id': userDoc.id, // Firestore document ID (used in Supabase as user_id)
              };

              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.person_outline,
                        color: Theme.of(context).primaryColor, size: 32),
                    title: Text(userData['fullName'] ?? 'N/A',
                        style: AppTextStyle.withWeight(
                            AppTextStyle.bodyMedium, FontWeight.bold)),
                    subtitle: Text(userData['email'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                          tooltip: "View User",
                          onPressed: () => viewUser(userWithId),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: "Delete User",
                          onPressed: () {
                            Get.defaultDialog(
                              title: "Delete User",
                              titleStyle: AppTextStyle.withColor(
                                  AppTextStyle.bodyMedium,
                                  Theme.of(context).primaryColor),
                              middleText:
                                  "Are you sure you want to delete this user?",
                              radius: 10,
                              confirm: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  deleteUser(userDoc.id);
                                  Get.back();
                                },
                                child: const Text("Delete",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              cancel: OutlinedButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
