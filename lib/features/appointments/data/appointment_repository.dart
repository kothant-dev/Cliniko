import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/db/database_provider.dart';
import 'package:cliniko/features/appointments/data/appointment_dao.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return AppointmentRepository(database.appointmentDao);
});

class AppointmentRepository {
  const AppointmentRepository(this._appointmentDao);

  final AppointmentDao _appointmentDao;

  Stream<List<AppointmentWithPatient>> watchAllAppointments() => _appointmentDao.watchAllAppointments();
  
  Stream<int> watchAppointmentCount() => _appointmentDao.watchAppointmentCount();

  Stream<List<Appointment>> watchAppointmentsForPatient(int patientId) =>
      _appointmentDao.watchAppointmentsForPatient(patientId);
  
  Future<int> addAppointment({
    required int patientId,
    required DateTime dateTime,
    String? notes,
  }) {
    return _appointmentDao.insertAppointment(AppointmentsCompanion.insert(
      patientId: patientId,
      datetime: dateTime,
      notes: Value(notes),
    ));
  }

  Future<bool> updateAppointment(Appointment appointment) => _appointmentDao.updateAppointment(appointment);
  
  Future<int> deleteAppointment(Appointment appointment) => _appointmentDao.deleteAppointment(appointment);
}
