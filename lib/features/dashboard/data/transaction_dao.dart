import 'package:cliniko/core/db/database.dart';
import 'package:drift/drift.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Patients])
class TransactionDao extends DatabaseAccessor<AppDatabase> with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<TransactionWithPatient>> watchAllTransactions() {
    final query = select(transactions).join([
      leftOuterJoin(patients, patients.id.equalsExp(transactions.patientId)),
    ]);
    
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithPatient(
          transaction: row.readTable(transactions),
          patient: row.readTableOrNull(patients),
        );
      }).toList();
    });
  }

  Future<int> insertTransaction(TransactionsCompanion entry) => into(transactions).insert(entry);
  
  Future<bool> updateTransaction(Transaction entry) => update(transactions).replace(entry);
  
  Future<int> deleteTransaction(Transaction entry) => delete(transactions).delete(entry);
}

class TransactionWithPatient {
  const TransactionWithPatient({required this.transaction, this.patient});

  final Transaction transaction;
  final Patient? patient;
}
