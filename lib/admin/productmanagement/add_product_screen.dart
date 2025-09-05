// ignore_for_file: depend_on_referenced_packages

import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/common/costomTextField.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Clothing',
    'Toys',
    'Cosmectic',
    'Baby Food',
    'Furniture',
    'Dipers'
  ];

  XFile? _pickedImage;
  bool isLoading = false;
  String error = '';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImage == null) {
      setState(() => error = 'Please select an image.');
      return;
    }

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final supabase = Supabase.instance.client;
      final uuid = Uuid().v4();
      final imageName = '${uuid}_${path.basename(_pickedImage!.path)}';
      final bucket = 'babyshop';
      final storage = supabase.storage.from(bucket);

      // Upload image based on platform
      if (kIsWeb) {
        final bytes = await _pickedImage!.readAsBytes();
        await storage.uploadBinary(
          'products/$imageName',
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
      } else {
        final file = File(_pickedImage!.path);
        await storage.upload(
          'products/$imageName',
          file,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
      }

      final imageUrl = storage.getPublicUrl('products/$imageName');

      await supabase.from('products').insert({
        'name': _productController.text.trim(),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'old_price': double.tryParse(_discountController.text),
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      _productController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _discountController.clear();
      _pickedImage = null;
      _selectedCategory = null;

      Get.snackbar("Success", "Product added successfully", snackPosition: SnackPosition.TOP);
      await Future.delayed(const Duration(seconds: 2));
      Get.back();
    } catch (e) {
      setState(() => error = 'Error adding product: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text(
          'Add Product',
          style: AppTextStyle.withColor(AppTextStyle.h3, Theme.of(context).primaryColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? Image.network(_pickedImage!.path).image
                                : FileImage(File(_pickedImage!.path)) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _pickedImage == null
                      ?  Center(child: Text("Tap to select image",
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        isDark ? Colors.white : Colors.grey
                      ),))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Product Name',
                prefixIcons: Icons.label_outline,
                controller: _productController,
                validator: (v) => v!.isEmpty ? 'Enter product name' : null,
              ),
              const SizedBox(height: 16),

              /// 👇 Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null ? 'Select a category' : null,
              ),

              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                prefixIcons: Icons.description_outlined,
                controller: _descriptionController,
                validator: (v) => v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Price',
                prefixIcons: Icons.attach_money,
                keyBoardType: TextInputType.number,
                controller: _priceController,
                validator: (v) => v!.isEmpty ? 'Enter price' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Discount Price',
                prefixIcons: Icons.money_off_csred_outlined,
                keyBoardType: TextInputType.number,
                controller: _discountController,
              ),
              const SizedBox(height: 24),
              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: isLoading ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Add Product", style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
