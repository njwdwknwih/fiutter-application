import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ProfileImageUploader extends StatefulWidget {
  const ProfileImageUploader({super.key});

  @override
  State<ProfileImageUploader> createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  XFile? _pickedImage;
  String? _imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadImageFromFirestore();
  }

  Future<void> _loadImageFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists && doc.data()!.containsKey('profile_img')) {
      setState(() {
        _imageUrl = doc['profile_img'];
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;

    setState(() {
      _pickedImage = picked;
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not signed in');
      return;
    }

    final uuid = const Uuid().v4();
    final fileName = '${uuid}_${path.basename(picked.path)}';
    final filePath = 'profile/${user.uid}/$fileName';

    try {
      final supabase = Supabase.instance.client;
      final storageRef = supabase.storage.from('profileimg');

      // Upload
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        await storageRef.uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));
      } else {
        await storageRef.upload(filePath, File(picked.path), fileOptions: const FileOptions(upsert: true));
      }

      final imageUrl = storageRef.getPublicUrl(filePath);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profile_img': imageUrl,
      });

      setState(() {
        _imageUrl = imageUrl;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar("Upload failed", "Error: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    bool hasImage = (_pickedImage != null) || (_imageUrl != null && _imageUrl!.isNotEmpty);

    if (_pickedImage != null) {
      imageProvider = kIsWeb
          ? NetworkImage(_pickedImage!.path)
          : FileImage(File(_pickedImage!.path)) as ImageProvider;
    } else if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_imageUrl!);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
  children: [
    GestureDetector(
      onTap: hasImage
          ? () => showDialog(
                context: context,
                builder: (context) => Dialog(
                  backgroundColor: Colors.black,
                  insetPadding: const EdgeInsets.all(16),
                  child: InteractiveViewer(
                    child: hasImage
                        ? (_pickedImage != null
                            ? kIsWeb
                                ? Image.network(_pickedImage!.path)
                                : Image.file(File(_pickedImage!.path))
                            : Image.network(_imageUrl!))
                        : const Icon(Icons.person, size: 100, color: Colors.white),
                  ),
                ),
              )
          : null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: hasImage ? imageProvider : null,
          child: !hasImage
              ? Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey[700],
                )
              : null,
        ),
      ),
    ),
    Positioned(
      bottom: 0,
      right: 4,
      child: GestureDetector(
        onTap: isLoading ? null : _pickAndUploadImage,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
    ),
  ],
),

        const SizedBox(height: 10),
        if (isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}
