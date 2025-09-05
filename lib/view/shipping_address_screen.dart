// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:babyshophub/models/address.dart';
import 'package:babyshophub/repositories/address_repository.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:babyshophub/view/wedgits/cart/address_card.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final AddressRepository repository = AddressRepository();
  List<Address> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final data = await repository.getAddresses();
    setState(() {
      _addresses = data;
    });
  }

  void _showAddressBottomSheet({Address? existing}) {
  final labelController = TextEditingController(text: existing?.label ?? '');
  final fullAddressController = TextEditingController(text: existing?.fullAddress ?? '');
  final cityController = TextEditingController(text: existing?.city ?? '');
  final stateController = TextEditingController(text: existing?.state ?? '');
  final zipController = TextEditingController(text: existing?.zipCode ?? '');
  bool isDefault = existing?.isDefault ?? false;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final isEditing = existing != null;

  Get.bottomSheet(
    StatefulBuilder(builder: (context, setState) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Address' : 'Add New Address',
                    style: AppTextStyle.withColor(
                      AppTextStyle.h3,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close,
                        color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(context, 'Home ,Office', Icons.label_outline, controller: labelController),
              const SizedBox(height: 16),
              _buildTextField(context, 'Full Address', Icons.location_on_outlined, controller: fullAddressController),
              const SizedBox(height: 16),
              _buildTextField(context, 'City', Icons.location_city_outlined, controller: cityController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(context, 'State', Icons.map_outlined, controller: stateController),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(context, 'ZIP Code', Icons.pin_outlined, controller: zipController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: isDefault,
                onChanged: (value) {
                  setState(() => isDefault = value ?? false);
                },
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  "Set as default address",
                  style: AppTextStyle.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final newAddress = Address(
                      id: existing?.id ?? '',
                      label: labelController.text.trim(),
                      fullAddress: fullAddressController.text.trim(),
                      city: cityController.text.trim(),
                      state: stateController.text.trim(),
                      zipCode: zipController.text.trim(),
                      isDefault: isDefault,
                    );
                    if (isEditing) {
                      await repository.updateAddress(newAddress);
                    } else {
                      await repository.addAddress(newAddress);
                    }
                    Get.back();
                    _loadAddresses();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Update Address' : 'Save Address',
                    style: AppTextStyle.withColor(AppTextStyle.buttonMedium, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }),
    isScrollControlled: true,
  );
}

  Widget _buildTextField(BuildContext context, String label, IconData icon, {TextEditingController? controller}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  void _confirmDelete(Address address) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: Colors.red, size: 40),
            const SizedBox(height: 16),
            Text('Delete Address?', style: AppTextStyle.h3),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete this address?', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await repository.deleteAddress(address.id);
                      Get.back();
                      _loadAddresses();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                      ),
                    child: Text('Delete',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonSmall,
                      Colors.white
                    ),),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.until((route) => route.isFirst),
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
        ),
        title: Text('Shipping Address', style: AppTextStyle.h3),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: isDark ? Colors.white : Colors.black),
            onPressed: () => _showAddressBottomSheet(),
          ),
        ],
      ),
      body: _addresses.isEmpty
          ? const Center(child: Text('No addresses found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                return AddressCard(
                  address: address,
                  onEdit: () => _showAddressBottomSheet(existing: address),
                  onDelete: () => _confirmDelete(address),
                );
              },
            ),
    );
  }
}
