import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import 'settings_subscreens/edit_profile_screen.dart';
import 'settings_subscreens/category_selector_screen.dart';
import 'settings_subscreens/privacy_screen.dart';
import 'settings_subscreens/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : const Color(0xFFF2F2F7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // Section 1: Profile
          _ProfileCard(user: user),
          
          // Section 2: Preferences
          const _SectionHeader(title: 'PREFERENCES'),
          const _PreferencesCard(),
          
          // Section 3: News
          const _SectionHeader(title: 'NEWS'),
          const _NewsCard(),
          
          // Section 4: Account
          const _SectionHeader(title: 'ACCOUNT'),
          const _AccountCard(),
        ],
      ),
    );
  }
}

// ── Profile Card ──────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final User? user;

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'S';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'S';
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName ?? 'SmartNews User';
    final email = user?.email ?? 'user@example.com';
    final initials = _initials(displayName);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F1FB), // Spec color
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF0C447C), // Spec color
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward, color: Color(0xFFC7C7CC), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Shared UI Helpers ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8E8E93),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.iconData,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showDivider = true,
    this.onTap,
    this.titleColor,
  });

  final IconData iconData;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowContent = Container(
      constraints: const BoxConstraints(minHeight: 52),
      child: Row(
        children: [
          const SizedBox(width: 12),
          if (iconColor != Colors.transparent)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Icon(iconData, size: 16, color: Colors.white),
            )
          else 
            SizedBox(width: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: titleColor ?? (isDark ? Colors.white : Colors.black),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93)),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            const SizedBox(width: 12),
          ] else if (onTap != null) ...[
             const Icon(CupertinoIcons.chevron_forward, color: Color(0xFFC7C7CC), size: 20),
             const SizedBox(width: 12),
          ],
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          rowContent,
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 52),
              child: Divider(
                height: 0.5,
                thickness: 0.5,
                color: isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Preferences Section ───────────────────────────────────────────────────────
class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return Consumer3<LanguageProvider, ThemeProvider, SettingsProvider>(
      builder: (context, langProvider, themeProvider, settingsProvider, _) {
        return _SettingsGroup(
          children: [
            _SettingRow(
              iconData: Icons.language,
              iconColor: const Color(0xFF007AFF),
              title: 'Language',
              trailing: Text(
                langProvider.getLanguageName(),
                style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
              ),
              onTap: () => _showLanguageModal(context, langProvider),
            ),
            _SettingRow(
              iconData: Icons.dark_mode,
              iconColor: const Color(0xFF5856D6),
              title: 'Dark Mode',
              trailing: CupertinoSwitch(
                value: themeProvider.isDark,
                activeTrackColor: const Color(0xFF1D9E75),
                inactiveTrackColor: const Color(0xFFB4B2A9),
                onChanged: (val) {
                  themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                },
              ),
              onTap: () {
                final isDark = themeProvider.isDark;
                themeProvider.setThemeMode(!isDark ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            _SettingRow(
              iconData: Icons.text_fields,
              iconColor: const Color(0xFFFF9500),
              title: 'Font Size',
              trailing: Text(
                settingsProvider.fontSize,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8E8E93)),
              ),
              showDivider: false,
              onTap: () => _showFontSizeModal(context, settingsProvider),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageModal(BuildContext context, LanguageProvider provider) {
    final options = LanguageProvider.getSupportedLanguages();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: options.entries.map((entry) {
          final isSelected = provider.currentLanguageCode == entry.key;
          return ListTile(
            title: Text(entry.value),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF007AFF)) : null,
            onTap: () {
              provider.setLanguage(entry.key);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showFontSizeModal(BuildContext context, SettingsProvider provider) {
    final sizes = ['Small', 'Medium', 'Large'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: sizes.map((size) {
          final isSelected = provider.fontSize == size;
          return ListTile(
            title: Text(size),
            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF007AFF)) : null,
            onTap: () {
              provider.setFontSize(size);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}

// ── News Section ──────────────────────────────────────────────────────────────
class _NewsCard extends StatelessWidget {
  const _NewsCard();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        final interestsList = provider.userInterests;
        final interestsText = interestsList.isNotEmpty ? interestsList.join(', ') : 'None selected';

        return _SettingsGroup(
          children: [
            _SettingRow(
              iconData: Icons.list,
              iconColor: const Color(0xFFFF2D55),
              title: 'My Interests',
              subtitle: interestsText,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategorySelectorScreen()),
              ),
            ),
            _SettingRow(
              iconData: Icons.notifications,
              iconColor: const Color(0xFFFF3B30),
              title: 'Notifications',
              trailing: CupertinoSwitch(
                value: provider.notificationsEnabled,
                activeTrackColor: const Color(0xFF1D9E75),
                inactiveTrackColor: const Color(0xFFB4B2A9),
                onChanged: provider.setNotificationsEnabled,
              ),
              showDivider: false,
              onTap: () {
                provider.setNotificationsEnabled(!provider.notificationsEnabled);
              },
            ),
          ],
        );
      },
    );
  }
}

// ── Account Section ───────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsGroup(
      children: [
        _SettingRow(
          iconData: Icons.shield,
          iconColor: const Color(0xFF34C759),
          title: 'Privacy & Security',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyScreen()),
          ),
        ),
        _SettingRow(
          iconData: Icons.info,
          iconColor: const Color(0xFF8E8E93),
          title: 'About SmartNews',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
        _SettingRow(
          iconData: Icons.logout,
          iconColor: Colors.transparent,
          title: 'Log Out',
          titleColor: const Color(0xFFFF3B30),
          onTap: () => _confirmAction(
            context,
            'Log Out',
            'Are you sure you want to log out?',
            () => AuthService.instance.signOut(),
          ),
        ),
        _SettingRow(
          iconData: Icons.delete_forever,
          iconColor: Colors.transparent,
          title: 'Delete Account',
          titleColor: const Color(0xFFFF3B30),
          showDivider: false,
          onTap: () => _confirmAction(
            context,
            'Delete Account',
            'Are you sure you want to permanently delete your account?',
            () {
              // Placeholder for delete
            },
          ),
        ),
      ],
    );
  }

  void _confirmAction(BuildContext context, String title, String message, VoidCallback onConfirm) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
