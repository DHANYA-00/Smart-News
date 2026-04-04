import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = categories[index];
          final isSelected = label == selected;

          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(label),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}