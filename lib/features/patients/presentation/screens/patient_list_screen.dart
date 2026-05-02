import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/core/widgets/glass_card.dart';
import 'package:cliniko/features/patients/data/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

final patientsStreamProvider = StreamProvider<List<Patient>>((ref) {
  return ref.watch(patientRepositoryProvider).watchAllPatients();
});

final patientCountProvider = StreamProvider<int>((ref) {
  return ref.watch(patientRepositoryProvider).watchPatientCount();
});

class PatientListScreen extends ConsumerWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(patientsStreamProvider);

    return Scaffold(
      body: patientsAsync.when(
        data: (patients) => patients.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildPatientList(context, ref, patients),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPatientDialog(context, ref),
        label: const Text('Add Patient'),
        icon: const Icon(LucideIcons.userPlus),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.users, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: AppTheme.space16),
          const Text('No patients yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space8),
          const Text('Add your first patient to get started'),
        ],
      ),
    );
  }

  Widget _buildPatientList(BuildContext context, WidgetRef ref, List<Patient> patients) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final patient = patients[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.space12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Text(patient.name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(patient.phone ?? 'No phone'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () {
                context.go('/patients/${patient.id}');
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              autofocus: true,
            ),
            const SizedBox(height: AppTheme.space16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await ref.read(patientRepositoryProvider).addPatient(
                  name: nameController.text,
                  phone: phoneController.text,
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
