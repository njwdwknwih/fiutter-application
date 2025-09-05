import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/product_controller.dart';
import '../../../utils/app_textsStyle.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<ProductController>();

    return Obx(() {
      return controller.categories.isEmpty
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(controller.categories.length, (index) {
                  final category = controller.categories[index];
                  final selected = controller.selectedCategory.value == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(
                        category,
                        style: AppTextStyle.withColor(
                          selected
                              ? AppTextStyle.withWeight(AppTextStyle.bodySmall, FontWeight.w600)
                              : AppTextStyle.bodySmall,
                          selected
                              ? Colors.white
                              : isDark
                                  ? Colors.grey[300]!
                                  : Colors.grey[600]!,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => controller.setCategoryFilter(category),
                      selectedColor: Theme.of(context).primaryColor,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
              ),
            );
    });
  }
}
