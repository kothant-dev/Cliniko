import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients, MedicalRecords])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  // ── Patient Queries ──────────────────────────────────────────────────

  Stream<List<Patient>> watchAllPatients() => select(patients).watch();

  Stream<Patient> watchPatientById(int id) {
    return (select(patients)..where((t) => t.id.equals(id))).watchSingle();
  }

  Future<Patient> getPatientById(int id) {
    return (select(patients)..where((t) => t.id.equals(id))).getSingle();
  }

  Stream<int> watchPatientCount() {
    final count = patients.id.count();
    final query = selectOnly(patients)..addColumns([count]);
    return query.map((row) => row.read(count)!).watchSingle();
  }

  Stream<List<Patient>> watchPaginatedPatients(int limit, int offset) {
    return (select(patients)..limit(limit, offset: offset)).watch();
  }

  Future<List<Patient>> getAllPatients() => select(patients).get();

  Future<int> insertPatient(PatientsCompanion entry) =>
      into(patients).insert(entry);

  Future<bool> updatePatient(Patient entry) => update(patients).replace(entry);

  Future<int> deletePatient(Patient entry) => delete(patients).delete(entry);

  Stream<List<Patient>> searchPatients(String query) {
    return (select(patients)..where((t) => t.name.contains(query))).watch();
  }

  // ── Medical Record Queries ───────────────────────────────────────────

  Stream<List<MedicalRecord>> watchMedicalRecordsForPatient(int patientId) {
    return (select(medicalRecords)
          ..where((t) => t.patientId.equals(patientId))
          ..orderBy([(t) => OrderingTerm.desc(t.visitDate)]))
        .watch();
  }

  Future<int> insertMedicalRecord(MedicalRecordsCompanion entry) =>
      into(medicalRecords).insert(entry);

  Future<bool> updateMedicalRecord(MedicalRecord entry) =>
      update(medicalRecords).replace(entry);

  Future<int> deleteMedicalRecord(MedicalRecord entry) =>
      delete(medicalRecords).delete(entry);
}
