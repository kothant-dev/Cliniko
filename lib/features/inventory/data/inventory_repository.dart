import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/db/database_provider.dart';
import 'package:cliniko/features/inventory/data/inventory_dao.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return InventoryRepository(database.inventoryDao);
});

class InventoryRepository {
  const InventoryRepository(this._inventoryDao);

  final InventoryDao _inventoryDao;

  Stream<List<Medicine>> watchAllMedicines() => _inventoryDao.watchAllMedicines();
  
  Future<int> addMedicine({
    required String name,
    String? batchNumber,
    DateTime? expiryDate,
    int stockQuantity = 0,
    double unitPrice = 0.0,
  }) {
    return _inventoryDao.insertMedicine(MedicinesCompanion.insert(
      name: name,
      batchNumber: Value(batchNumber),
      expiryDate: Value(expiryDate),
      stockQuantity: Value(stockQuantity),
      unitPrice: Value(unitPrice),
    ));
  }

  Future<bool> updateMedicine(Medicine medicine) => _inventoryDao.updateMedicine(medicine);
  
  Future<int> deleteMedicine(Medicine medicine) => _inventoryDao.deleteMedicine(medicine);
}
