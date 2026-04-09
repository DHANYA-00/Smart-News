import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final languages = LanguageProvider.getSupportedLanguages();
        final currentLanguage = languageProvider.currentLanguageCode;

        return AlertDialog(
          title: const Text('Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.entries.map((entry) {
                final code = entry.key;
                final name = entry.value;
                final isSelected = code == currentLanguage;

                return ListTile(
                  title: Text(name),
                  trailing: isSelected
                      ? Icon(Icons.check,
                          color: Theme.of(context).primaryColor)
                      : null,
                  selected: isSelected,
                  onTap: () {
                    if (code != currentLanguage) {
                      languageProvider.setLanguage(code);
                    }
                    Navigator.of(context).pop();
                  },
                  selectedTileColor:
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

/// Simple floating action button that opens language selector
class LanguageSelectorFAB extends StatelessWidget {
  const LanguageSelectorFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        return FloatingActionButton(
          tooltip: 'Change Language',
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const LanguageSelectorWidget(),
            );
          },
          child: Text(
            languageProvider.currentLanguageCode.toUpperCase(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

/// Simple language selector dropdown (can be used in AppBar or settings)
class LanguageSelectorDropdown extends StatelessWidget {
  final EdgeInsets padding;

  const LanguageSelectorDropdown({super.key, this.padding = const EdgeInsets.all(8.0)});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        final languages = LanguageProvider.getSupportedLanguages();

        return Padding(
          padding: padding,
          child: DropdownButton<String>(
            value: languageProvider.currentLanguageCode,
            onChanged: (value) {
              if (value != null) {
                languageProvider.setLanguage(value);
              }
            },
            items: languages.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
