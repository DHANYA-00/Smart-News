import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class CategorySelectorScreen extends StatelessWidget {
  const CategorySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableCategories = [
      'Sports', 'Politics', 'Technology', 'Business', 'Entertainment',
      'Health', 'Science', 'World', 'Crime', 'Education'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(title: const Text('My Interests')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            itemCount: availableCategories.length,
            itemBuilder: (context, index) {
              final cat = availableCategories[index];
              final isSelected = provider.userInterests.contains(cat);
              return CheckboxListTile(
                title: Text(cat),
                value: isSelected,
                onChanged: (val) {
                  if (val == true) {
                    provider.addInterest(cat);
                  } else {
                    provider.removeInterest(cat);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
