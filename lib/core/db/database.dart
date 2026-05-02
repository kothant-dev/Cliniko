import 'dart:io';

import 'package:cliniko/features/appointments/data/appointment_dao.dart';
import 'package:cliniko/features/dashboard/data/transaction_dao.dart';
import 'package:cliniko/features/inventory/data/inventory_dao.dart';
import 'package:cliniko/features/patients/data/patient_dao.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get gender => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class MedicalRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get visitDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get prescriptionText => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().references(Patients, #id)();
  DateTimeColumn get datetime => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, completed, cancelled
  TextColumn get notes => text().nullable()();
}

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get patientId => integer().nullable().references(Patients, #id)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // income, expense
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  IntColumn get entityId => integer()();
  TextColumn get action => text()(); // create, update, delete
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Patients,
    MedicalRecords,
    Appointments,
    Medicines,
    Transactions,
    AuditLogs,
  ],
  daos: [
    PatientDao,
    AppointmentDao,
    InventoryDao,
    TransactionDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // If we added new tables, this will create them if they don't exist
          await m.createAll();
        }
      },
      beforeOpen: (details) async {
        if (details.wasCreated) {
          // You could seed data here, but we'll do it via a separate service
        }
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
