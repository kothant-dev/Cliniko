import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

part 'patient_dao.g.dart';

@DriftAccessor(tables: [Patients])
class PatientDao extends DatabaseAccessor<AppDatabase> with _$PatientDaoMixin {
  PatientDao(super.db);

  Stream<List<Patient>> watchAllPatients() => select(patients).watch();
  
  Future<List<Patient>> getAllPatients() => select(patients).get();
  
  Future<int> insertPatient(PatientsCompanion entry) => into(patients).insert(entry);
  
  Future<bool> updatePatient(Patient entry) => update(patients).replace(entry);
  
  Future<int> deletePatient(Patient entry) => delete(patients).delete(entry);

  Stream<List<Patient>> searchPatients(String query) {
    return (select(patients)..where((t) => t.name.contains(query))).watch();
  }
}
