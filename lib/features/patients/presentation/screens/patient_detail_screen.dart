import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/core/widgets/glass_card.dart';
import 'package:cliniko/features/appointments/data/appointment_repository.dart';
import 'package:cliniko/features/patients/data/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({required this.patientId, super.key});

  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(
      StreamProvider<Patient>(
        (ref) => ref.watch(patientRepositoryProvider).watchPatientById(patientId),
      ),
    );

    return patientAsync.when(
      data: (patient) => _PatientDetailBody(patient: patient),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }
}

class _PatientDetailBody extends ConsumerStatefulWidget {
  const _PatientDetailBody({required this.patient});
  final Patient patient;

  @override
  ConsumerState<_PatientDetailBody> createState() => _PatientDetailBodyState();
}

class _PatientDetailBodyState extends ConsumerState<_PatientDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildHeader(context, patient, theme)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.disabledColor,
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(icon: Icon(LucideIcons.user), text: 'Overview'),
                  Tab(icon: Icon(LucideIcons.fileText), text: 'Records'),
                  Tab(icon: Icon(LucideIcons.calendar), text: 'Appointments'),
                ],
              ),
              theme.colorScheme.surface,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(patient: patient),
            _MedicalRecordsTab(patientId: patient.id),
            _AppointmentsTab(patientId: patient.id),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Patient patient, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.go('/patients'),
          ),
          const SizedBox(width: AppTheme.space12),
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            foregroundColor: theme.colorScheme.primary,
            child: Text(
              patient.name[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  patient.phone ?? 'No phone on file',
                  style: TextStyle(color: theme.disabledColor),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.edit),
            tooltip: 'Edit Patient',
            onPressed: () => _showEditDialog(context, patient),
          ),
          IconButton(
            icon: Icon(LucideIcons.trash2, color: theme.colorScheme.error),
            tooltip: 'Delete Patient',
            onPressed: () => _showDeleteConfirmation(context, patient),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Patient patient) {
    final nameCtrl = TextEditingController(text: patient.name);
    final phoneCtrl = TextEditingController(text: patient.phone ?? '');
    final addressCtrl = TextEditingController(text: patient.address ?? '');
    String? selectedGender = patient.gender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Patient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: AppTheme.space12),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                const SizedBox(height: AppTheme.space12),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => selectedGender = v),
                ),
                const SizedBox(height: AppTheme.space12),
                TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty) {
                  await ref.read(patientRepositoryProvider).updatePatient(
                    patient.copyWith(
                      name: nameCtrl.text,
                      phone: Value(phoneCtrl.text.isEmpty ? null : phoneCtrl.text),
                      gender: Value(selectedGender),
                      address: Value(addressCtrl.text.isEmpty ? null : addressCtrl.text),
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              await ref.read(patientRepositoryProvider).deletePatient(patient);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/patients');
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.patient});
  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return ListView(
      padding: const EdgeInsets.all(AppTheme.space16),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              const SizedBox(height: AppTheme.space16),
              _infoRow(context, LucideIcons.phone, 'Phone', patient.phone ?? 'Not provided'),
              _infoRow(context, LucideIcons.user, 'Gender', patient.gender ?? 'Not specified'),
              _infoRow(context, LucideIcons.cake, 'Date of Birth', patient.dateOfBirth != null ? dateFormat.format(patient.dateOfBirth!) : 'Not provided'),
              _infoRow(context, LucideIcons.mapPin, 'Address', patient.address ?? 'Not provided'),
              const Divider(height: AppTheme.space24),
              _infoRow(context, LucideIcons.calendarDays, 'Registered', dateFormat.format(patient.createdAt)),
              _infoRow(context, LucideIcons.refreshCw, 'Last Updated', dateFormat.format(patient.updatedAt)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).disabledColor),
          const SizedBox(width: AppTheme.space12),
          SizedBox(width: 110, child: Text(label, style: TextStyle(color: Theme.of(context).disabledColor, fontSize: 13))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

// ── Medical Records Tab ──────────────────────────────────────────────

class _MedicalRecordsTab extends ConsumerWidget {
  const _MedicalRecordsTab({required this.patientId});
  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(
      StreamProvider<List<MedicalRecord>>(
        (ref) => ref.watch(patientRepositoryProvider).watchMedicalRecordsForPatient(patientId),
      ),
    );

    return Scaffold(
      body: recordsAsync.when(
        data: (records) => records.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.fileX, size: 48, color: Theme.of(context).disabledColor),
                    const SizedBox(height: 16),
                    const Text('No medical records yet'),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppTheme.space16),
                itemCount: records.length,
                itemBuilder: (context, index) => _buildRecordCard(context, ref, records[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'addRecord',
        onPressed: () => _showAddRecordDialog(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, WidgetRef ref, MedicalRecord record) {
    final dateFormat = DateFormat('MMM dd, yyyy – HH:mm');
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.stethoscope, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppTheme.space8),
                Text(dateFormat.format(record.visitDate), style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor)),
                const Spacer(),
                IconButton(
                  icon: Icon(LucideIcons.trash2, size: 16, color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    await ref.read(patientRepositoryProvider).deleteMedicalRecord(record);
                  },
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete record',
                ),
              ],
            ),
            if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space8),
              Text('Diagnosis', style: TextStyle(fontSize: 11, color: Theme.of(context).disabledColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(record.diagnosis!, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space8),
              Text('Notes', style: TextStyle(fontSize: 11, color: Theme.of(context).disabledColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(record.notes!),
            ],
            if (record.prescriptionText != null && record.prescriptionText!.isNotEmpty) ...[
              const SizedBox(height: AppTheme.space8),
              Text('Prescription', style: TextStyle(fontSize: 11, color: Theme.of(context).disabledColor, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(record.prescriptionText!, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, WidgetRef ref) {
    final diagnosisCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final prescriptionCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Medical Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: diagnosisCtrl, decoration: const InputDecoration(labelText: 'Diagnosis')),
              const SizedBox(height: AppTheme.space12),
              TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
              const SizedBox(height: AppTheme.space12),
              TextField(controller: prescriptionCtrl, decoration: const InputDecoration(labelText: 'Prescription'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(patientRepositoryProvider).addMedicalRecord(
                patientId: patientId,
                diagnosis: diagnosisCtrl.text.isEmpty ? null : diagnosisCtrl.text,
                notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                prescriptionText: prescriptionCtrl.text.isEmpty ? null : prescriptionCtrl.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ── Appointments Tab ─────────────────────────────────────────────────

class _AppointmentsTab extends ConsumerWidget {
  const _AppointmentsTab({required this.patientId});
  final int patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apptAsync = ref.watch(
      StreamProvider<List<Appointment>>(
        (ref) => ref.watch(appointmentRepositoryProvider).watchAppointmentsForPatient(patientId),
      ),
    );

    return apptAsync.when(
      data: (appointments) => appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.calendarOff, size: 48, color: Theme.of(context).disabledColor),
                  const SizedBox(height: 16),
                  const Text('No appointments yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.space16),
              itemCount: appointments.length,
              itemBuilder: (context, index) => _buildApptCard(context, appointments[index]),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildApptCard(BuildContext context, Appointment appt) {
    final dateFormat = DateFormat('MMM dd, yyyy – HH:mm');
    final isPast = appt.datetime.isBefore(DateTime.now());

    Color statusColor;
    switch (appt.status) {
      case 'completed': statusColor = Colors.green;
      case 'cancelled': statusColor = Colors.red;
      default: statusColor = Colors.orange;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              color: (isPast ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              isPast ? LucideIcons.calendarCheck : LucideIcons.calendarClock,
              color: isPast ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(dateFormat.format(appt.datetime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(appt.notes ?? 'No notes', maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              appt.status.toUpperCase(),
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tab Bar Delegate ─────────────────────────────────────────────────

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(this.tabBar, this.color);
  final TabBar tabBar;
  final Color color;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: color, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
