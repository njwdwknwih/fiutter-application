import 'package:babyshophub/models/address.dart';
import 'package:babyshophub/repositories/address_repository.dart';
import 'package:babyshophub/utils/app_textsStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressCardScreen extends StatefulWidget {
  const AddressCardScreen({super.key});

  @override
  State<AddressCardScreen> createState() => _AddressCardScreenState();
}

class _AddressCardScreenState extends State<AddressCardScreen> {
  final AddressRepository repository = AddressRepository();
  Address? _defaultAddress;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    final addresses = await repository.getAddresses();
    setState(() {
      _defaultAddress = addresses.firstWhere(
        (addr) => addr.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : Address.empty(),
      );
    });
  }

  void _editAddressBottomSheet(Address address) {
    final labelController = TextEditingController(text: address.label);
    final fullAddressController = TextEditingController(text: address.fullAddress);
    final cityController = TextEditingController(text: address.city);
    final stateController = TextEditingController(text: address.state);
    final zipController = TextEditingController(text: address.zipCode);
    bool isDefault = address.isDefault;

    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    Text('Edit Address', style: AppTextStyle.h3),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField('Label', Icons.label, labelController),
                const SizedBox(height: 16),
                _buildTextField('Full Address', Icons.location_on, fullAddressController),
                const SizedBox(height: 16),
                _buildTextField('City', Icons.location_city, cityController),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField('State', Icons.map, stateController)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildTextField('ZIP Code', Icons.pin_drop, zipController)),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (value) {
                    setState(() => isDefault = value ?? false);
                  },
                  title: const Text('Set as default address'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final updated = Address(
                      id: address.id,
                      label: labelController.text,
                      fullAddress: fullAddressController.text,
                      city: cityController.text,
                      state: stateController.text,
                      zipCode: zipController.text,
                      isDefault: isDefault,
                    );

                    await repository.updateAddress(updated);
                    Get.back();
                    _loadDefaultAddress();
                  },
                  child: const Text('Update Address'),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_defaultAddress == null || _defaultAddress!.id.isEmpty) {
      return const Text('No address found.');
    }

    return GestureDetector(
      onTap: () => _editAddressBottomSheet(_defaultAddress!),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(_defaultAddress!.label, style: AppTextStyle.bodyLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_defaultAddress!.fullAddress}, ${_defaultAddress!.city}, ${_defaultAddress!.state}, ${_defaultAddress!.zipCode}',
              style: AppTextStyle.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}