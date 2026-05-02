import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

part 'appointment_dao.g.dart';

@DriftAccessor(tables: [Appointments, Patients])
class AppointmentDao extends DatabaseAccessor<AppDatabase> with _$AppointmentDaoMixin {
  AppointmentDao(super.db);

  Stream<List<AppointmentWithPatient>> watchAllAppointments() {
    final query = select(appointments).join([
      innerJoin(patients, patients.id.equalsExp(appointments.patientId)),
    ]);
    
    return query.watch().map((rows) {
      return rows.map((row) {
        return AppointmentWithPatient(
          appointment: row.readTable(appointments),
          patient: row.readTable(patients),
        );
      }).toList();
    });
  }
  
  Stream<int> watchAppointmentCount() {
    final count = appointments.id.count();
    final query = selectOnly(appointments)..addColumns([count]);
    return query.map((row) => row.read(count)!).watchSingle();
  }

  Stream<List<Appointment>> watchAppointmentsForPatient(int patientId) {
    return (select(appointments)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm.desc(t.datetime)]))
        .watch();
  }

  Future<int> insertAppointment(AppointmentsCompanion entry) => into(appointments).insert(entry);
  
  Future<bool> updateAppointment(Appointment entry) => update(appointments).replace(entry);
  
  Future<int> deleteAppointment(Appointment entry) => delete(appointments).delete(entry);
}

class AppointmentWithPatient {
  const AppointmentWithPatient({required this.appointment, required this.patient});

  final Appointment appointment;
  final Patient patient;
}
