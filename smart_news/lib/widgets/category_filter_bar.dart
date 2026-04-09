import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /// Get color for category chip
  Color _getCategoryColor(BuildContext context, String category) {
    final primary = Theme.of(context).colorScheme.primary;
    switch (category.toLowerCase()) {
      case 'sports':
        return const Color(0xFF34A853); // Green
      case 'politics':
        return const Color(0xFFFBBC04); // Yellow/Gold
      case 'technology':
        return primary; // Blue
      case 'business':
        return const Color(0xFFEA4335); // Red
      case 'science':
        return const Color(0xFF4285F4); // Light Blue
      case 'health':
        return const Color(0xFF34A853); // Green
      case 'entertainment':
        return const Color(0xFFAA00FF); // Purple
      case 'general':
      default:
        return const Color(0xFF5F6368); // Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          final color = _getCategoryColor(context, category);
          final theme = Theme.of(context);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              backgroundColor: Colors.transparent,
              selectedColor: color.withValues(alpha: 0.2),
              onSelected: (selected) {
                onCategorySelected(category);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? color : theme.dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? color : theme.textTheme.labelMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
