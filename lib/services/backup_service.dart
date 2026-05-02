import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cliniko/core/db/database.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  const BackupService(this._db);

  final AppDatabase _db;

  Future<String> exportBackup() async {
    final data = <String, dynamic>{};

    // Export each table
    data['patients'] = (await _db.select(_db.patients).get()).map((e) => e.toJson()).toList();
    data['medical_records'] = (await _db.select(_db.medicalRecords).get()).map((e) => e.toJson()).toList();
    data['appointments'] = (await _db.select(_db.appointments).get()).map((e) => e.toJson()).toList();
    data['medicines'] = (await _db.select(_db.medicines).get()).map((e) => e.toJson()).toList();
    data['transactions'] = (await _db.select(_db.transactions).get()).map((e) => e.toJson()).toList();

    final jsonString = jsonEncode(data);
    final archive = Archive();
    final fileData = utf8.encode(jsonString);
    archive.addFile(ArchiveFile('cliniko_backup.json', fileData.length, fileData));

    final zipData = ZipEncoder().encode(archive);
    if (zipData == null) throw Exception('Failed to encode ZIP');

    final directory = await getApplicationDocumentsDirectory();
    final backupFile = File('${directory.path}/cliniko_backup_${DateTime.now().millisecondsSinceEpoch}.zip');
    await backupFile.writeAsBytes(zipData);

    return backupFile.path;
  }

  Future<void> importBackup(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final jsonFile = archive.findFile('cliniko_backup.json');
    if (jsonFile == null) throw Exception('Invalid backup file');

    final jsonString = utf8.decode(jsonFile.content);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    await _db.transaction(() async {
      // Clear existing data
      await _db.delete(_db.patients).go();
      await _db.delete(_db.medicalRecords).go();
      await _db.delete(_db.appointments).go();
      await _db.delete(_db.medicines).go();
      await _db.delete(_db.transactions).go();

      // Restore data
      for (final p in data['patients']) {
        await _db.into(_db.patients).insert(Patient.fromJson(p));
      }
      for (final r in data['medical_records']) {
        await _db.into(_db.medicalRecords).insert(MedicalRecord.fromJson(r));
      }
      for (final a in data['appointments']) {
        await _db.into(_db.appointments).insert(Appointment.fromJson(a));
      }
      for (final m in data['medicines']) {
        await _db.into(_db.medicines).insert(Medicine.fromJson(m));
      }
      for (final t in data['transactions']) {
        await _db.into(_db.transactions).insert(Transaction.fromJson(t));
      }
    });
  }
}
