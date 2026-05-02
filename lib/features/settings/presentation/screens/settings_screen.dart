import 'package:cliniko/core/db/database_provider.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/services/backup_service.dart';
import 'package:cliniko/services/demo_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.space24),
        children: [
          _buildSection(
            context,
            'Clinic Information',
            [
              _buildSettingTile(
                icon: LucideIcons.building,
                title: 'Clinic Name',
                subtitle: 'Cliniko Wellness Center',
                onTap: () {},
              ),
              _buildSettingTile(
                icon: LucideIcons.phone,
                title: 'Contact Phone',
                subtitle: '+1 (555) 012-3456',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space24),
          _buildSection(
            context,
            'Data & Backup',
            [
              _buildSettingTile(
                icon: LucideIcons.database,
                title: 'Seed Demo Data',
                subtitle: 'Populate the database with test data',
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  final service = DemoDataService(db);
                  try {
                    await service.seedData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo data seeded successfully!')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
              _buildSettingTile(
                icon: LucideIcons.download,
                title: 'Export Data',
                subtitle: 'Download a backup of your clinic data (ZIP)',
                onTap: () async {
                  final db = ref.read(databaseProvider);
                  final service = BackupService(db);
                  try {
                    final path = await service.exportBackup();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved to: $path')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              ),
              _buildSettingTile(
                icon: LucideIcons.upload,
                title: 'Import Data',
                subtitle: 'Restore your clinic data from a ZIP backup',
                onTap: () {
                  // Implement file picker logic
                },
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space24),
          _buildSection(
            context,
            'Appearance',
            [
              SwitchListTile(
                secondary: const Icon(LucideIcons.moon),
                title: const Text('Dark Mode'),
                value: Theme.of(context).brightness == Brightness.dark,
                onChanged: (val) {},
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space48),
          Center(
            child: Text(
              'Cliniko v1.0.0\nFully Offline • Private • Secure',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: AppTheme.space12),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16),
      onTap: onTap,
    );
  }
}
