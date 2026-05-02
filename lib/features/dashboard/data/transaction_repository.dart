import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/db/database_provider.dart';
import 'package:cliniko/features/dashboard/data/transaction_dao.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionRepository(database.transactionDao);
});

class TransactionRepository {
  const TransactionRepository(this._transactionDao);

  final TransactionDao _transactionDao;

  Stream<List<TransactionWithPatient>> watchAllTransactions() => _transactionDao.watchAllTransactions();
  
  Future<int> addTransaction({
    required double amount,
    required String type,
    int? patientId,
  }) {
    return _transactionDao.insertTransaction(TransactionsCompanion.insert(
      patientId: Value(patientId),
      amount: amount,
      type: type,
    ));
  }

  Future<bool> updateTransaction(Transaction transaction) => _transactionDao.updateTransaction(transaction);
  
  Future<int> deleteTransaction(Transaction transaction) => _transactionDao.deleteTransaction(transaction);
}
