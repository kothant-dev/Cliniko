import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/db/database_provider.dart';
import 'package:cliniko/features/patients/data/patient_dao.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return PatientRepository(database.patientDao);
});

class PatientRepository {
  const PatientRepository(this._patientDao);

  final PatientDao _patientDao;

  // ── Patient ────────────────────────────────────────────────────────

  Stream<List<Patient>> watchAllPatients() => _patientDao.watchAllPatients();

  Stream<Patient> watchPatientById(int id) =>
      _patientDao.watchPatientById(id);

  Future<Patient> getPatientById(int id) => _patientDao.getPatientById(id);

  Stream<int> watchPatientCount() => _patientDao.watchPatientCount();

  Stream<List<Patient>> watchPaginatedPatients(int limit, int offset) =>
      _patientDao.watchPaginatedPatients(limit, offset);

  Future<List<Patient>> getAllPatients() => _patientDao.getAllPatients();

  Future<int> addPatient({
    required String name,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
  }) {
    return _patientDao.insertPatient(PatientsCompanion.insert(
      name: name,
      phone: Value(phone),
      gender: Value(gender),
      dateOfBirth: Value(dateOfBirth),
      address: Value(address),
    ));
  }

  Future<bool> updatePatient(Patient patient) =>
      _patientDao.updatePatient(patient);

  Future<int> deletePatient(Patient patient) =>
      _patientDao.deletePatient(patient);

  Stream<List<Patient>> searchPatients(String query) =>
      _patientDao.searchPatients(query);

  // ── Medical Records ────────────────────────────────────────────────

  Stream<List<MedicalRecord>> watchMedicalRecordsForPatient(int patientId) =>
      _patientDao.watchMedicalRecordsForPatient(patientId);

  Future<int> addMedicalRecord({
    required int patientId,
    String? diagnosis,
    String? notes,
    String? prescriptionText,
  }) {
    return _patientDao.insertMedicalRecord(MedicalRecordsCompanion.insert(
      patientId: patientId,
      diagnosis: Value(diagnosis),
      notes: Value(notes),
      prescriptionText: Value(prescriptionText),
    ));
  }

  Future<int> deleteMedicalRecord(MedicalRecord record) =>
      _patientDao.deleteMedicalRecord(record);
}
