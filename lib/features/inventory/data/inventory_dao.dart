import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(tables: [Medicines])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);

  Stream<List<Medicine>> watchAllMedicines() => select(medicines).watch();
  
  Stream<int> watchLowStockCount(int threshold) {
    final count = medicines.id.count();
    final query = selectOnly(medicines)
      ..addColumns([count])
      ..where(medicines.stockQuantity.isSmallerThanValue(threshold));
    return query.map((row) => row.read(count)!).watchSingle();
  }
  
  Future<List<Medicine>> getAllMedicines() => select(medicines).get();
  
  Future<int> insertMedicine(MedicinesCompanion entry) => into(medicines).insert(entry);
  
  Future<bool> updateMedicine(Medicine entry) => update(medicines).replace(entry);
  
  Future<int> deleteMedicine(Medicine entry) => delete(medicines).delete(entry);
}
