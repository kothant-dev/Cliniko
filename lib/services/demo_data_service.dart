import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

class DemoDataService {
  const DemoDataService(this._db);

  final AppDatabase _db;

  Future<void> seedData() async {
    // Check if data already exists
    final patientCount = await _db.select(_db.patients).get();
    if (patientCount.isNotEmpty) return;

    await _db.transaction(() async {
      // 1. Seed Patients
      final patients = [
        PatientsCompanion.insert(
          name: 'Sarah Connor',
          phone: const Value('555-0101'),
          gender: const Value('Female'),
          dateOfBirth: Value(DateTime(1985, 5, 12)),
          address: const Value('734 Ocean Ave, Santa Monica'),
        ),
        PatientsCompanion.insert(
          name: 'Arthur Dent',
          phone: const Value('555-4242'),
          gender: const Value('Male'),
          dateOfBirth: Value(DateTime(1979, 10, 12)),
          address: const Value('The Galaxy'),
        ),
        PatientsCompanion.insert(
          name: 'Ellen Ripley',
          phone: const Value('555-1979'),
          gender: const Value('Female'),
          dateOfBirth: Value(DateTime(2092, 1, 7)),
          address: const Value('Nostromo Station'),
        ),
        PatientsCompanion.insert(
          name: 'Tony Stark',
          phone: const Value('555-3000'),
          gender: const Value('Male'),
          dateOfBirth: Value(DateTime(1970, 5, 29)),
          address: const Value('10880 Malibu Point'),
        ),
        PatientsCompanion.insert(
          name: 'Bruce Wayne',
          phone: const Value('555-0000'),
          gender: const Value('Male'),
          dateOfBirth: Value(DateTime(1980, 2, 19)),
          address: const Value('Wayne Manor, Gotham'),
        ),
      ];

      final patientIds = <int>[];
      for (final p in patients) {
        patientIds.add(await _db.into(_db.patients).insert(p));
      }

      // 2. Seed Medicines
      final medicines = [
        MedicinesCompanion.insert(
          name: 'Paracetamol 500mg',
          batchNumber: const Value('BATCH-001'),
          stockQuantity: const Value(500),
          unitPrice: const Value(0.10),
          expiryDate: Value(DateTime.now().add(const Duration(days: 365))),
        ),
        MedicinesCompanion.insert(
          name: 'Amoxicillin 250mg',
          batchNumber: const Value('BATCH-002'),
          stockQuantity: const Value(5), // Low stock alert
          unitPrice: const Value(1.50),
          expiryDate: Value(DateTime.now().add(const Duration(days: 15))), // Near expiry
        ),
        MedicinesCompanion.insert(
          name: 'Ibuprofen 400mg',
          batchNumber: const Value('BATCH-003'),
          stockQuantity: const Value(200),
          unitPrice: const Value(0.50),
          expiryDate: Value(DateTime.now().add(const Duration(days: 500))),
        ),
        MedicinesCompanion.insert(
          name: 'Cetirizine 10mg',
          batchNumber: const Value('BATCH-004'),
          stockQuantity: const Value(8), // Low stock
          unitPrice: const Value(0.30),
          expiryDate: Value(DateTime.now().add(const Duration(days: 200))),
        ),
      ];

      for (final m in medicines) {
        await _db.into(_db.medicines).insert(m);
      }

      // 3. Seed Appointments
      final appointments = [
        AppointmentsCompanion.insert(
          patientId: patientIds[0],
          datetime: DateTime.now().add(const Duration(hours: 2)),
          notes: const Value('General Checkup'),
        ),
        AppointmentsCompanion.insert(
          patientId: patientIds[1],
          datetime: DateTime.now().add(const Duration(hours: 4)),
          notes: const Value('Dental Cleaning'),
        ),
        AppointmentsCompanion.insert(
          patientId: patientIds[2],
          datetime: DateTime.now().add(const Duration(days: 1, hours: 2)),
          notes: const Value('Follow-up'),
        ),
      ];

      for (final a in appointments) {
        await _db.into(_db.appointments).insert(a);
      }

      // 4. Seed Transactions
      final transactions = [
        TransactionsCompanion.insert(
          patientId: Value(patientIds[0]),
          amount: 50.0,
          type: 'income',
        ),
        TransactionsCompanion.insert(
          patientId: Value(patientIds[3]),
          amount: 1500.0,
          type: 'income',
        ),
        TransactionsCompanion.insert(
          amount: 200.0, // Clinic expense (e.g., rent)
          type: 'expense',
        ),
      ];

      for (final t in transactions) {
        await _db.into(_db.transactions).insert(t);
      }
    });
  }
}
