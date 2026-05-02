import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/core/widgets/glass_card.dart';
import 'package:cliniko/features/appointments/data/appointment_dao.dart';
import 'package:cliniko/features/appointments/data/appointment_repository.dart';
import 'package:cliniko/features/patients/data/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';

final appointmentsStreamProvider = StreamProvider<List<AppointmentWithPatient>>((ref) {
  return ref.watch(appointmentRepositoryProvider).watchAllAppointments();
});

final appointmentCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appointmentRepositoryProvider).watchAppointmentCount();
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsAsync = ref.watch(appointmentsStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildCalendar(),
          const Divider(height: 1),
          Expanded(
            child: appointmentsAsync.when(
              data: (appointments) => _buildAppointmentList(appointments),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAppointmentDialog(context),
        label: const Text('Schedule'),
        icon: const Icon(LucideIcons.calendarPlus),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<AppointmentWithPatient> appointments) {
    final filtered = appointments.where((a) => isSameDay(a.appointment.datetime, _selectedDay)).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.calendarOff, size: 48, color: Theme.of(context).disabledColor),
            const SizedBox(height: 16),
            const Text('No appointments for this day'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.space12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
              leading: Container(
                padding: const EdgeInsets.all(AppTheme.space8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(item.appointment.datetime), 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      )
                    ),
                  ],
                ),
              ),
              title: Text(item.patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                item.appointment.notes?.isNotEmpty == true ? item.appointment.notes! : 'No notes provided',
                style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: _StatusBadge(status: item.appointment.status),
            ),
          ),
        );
      },
    );
  }

  void _showAddAppointmentDialog(BuildContext context) async {
    final patientsAsync = await ref.read(patientRepositoryProvider).getAllPatients();
    if (!context.mounted) return;

    if (patientsAsync.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a patient first')));
      return;
    }

    Patient? selectedPatient;
    TimeOfDay? selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final notesController = TextEditingController();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Patient>(
                  decoration: const InputDecoration(labelText: 'Patient'),
                  items: patientsAsync.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (val) => setState(() => selectedPatient = val),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Time'),
                  trailing: Text(selectedTime?.format(context) ?? 'Select'),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: selectedTime!);
                    if (time != null) setState(() => selectedTime = time);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedPatient != null && _selectedDay != null) {
                  final appointmentDateTime = DateTime(
                    _selectedDay!.year,
                    _selectedDay!.month,
                    _selectedDay!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );
                  await ref.read(appointmentRepositoryProvider).addAppointment(
                    patientId: selectedPatient!.id,
                    dateTime: appointmentDateTime,
                    notes: notesController.text,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed': color = Colors.green; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
