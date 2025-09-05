import 'package:babyshophub/models/address.dart';
import 'package:flutter/material.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final bool showChangeButton;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onChange;

  const AddressCard({
    super.key,
    required this.address,
    this.showChangeButton = true,
    this.onEdit,
    this.onDelete,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                address.label,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${address.fullAddress}, ${address.city}, ${address.state}, ${address.zipCode}',
            style: theme.textTheme.bodyMedium,
          ),
          if (address.isDefault)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Chip(
                label: const Text('Default'),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showChangeButton) const SizedBox(height: 16),
          if (showChangeButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).primaryColor),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ],
            ),
        ],
      ),
    );
  }
}
