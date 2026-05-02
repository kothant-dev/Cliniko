import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/features/dashboard/data/transaction_dao.dart';
import 'package:cliniko/features/dashboard/data/transaction_repository.dart';
import 'package:cliniko/features/patients/data/patient_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

final transactionsStreamProvider = StreamProvider<List<TransactionWithPatient>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAllTransactions();
});

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return Scaffold(
      body: transactionsAsync.when(
        data: (transactions) => transactions.isEmpty
            ? _buildEmptyState(context)
            : _buildTransactionList(context, ref, transactions),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context, ref),
        label: const Text('Add Transaction'),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.dollarSign, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          const Text('No transactions yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Record your first income or expense'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, WidgetRef ref, List<TransactionWithPatient> transactions) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final item = transactions[index];
        final isIncome = item.transaction.type == 'income';

        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.space12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              child: Icon(
                isIncome ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight,
                color: isIncome ? Colors.green : Colors.red,
                size: 18,
              ),
            ),
            title: Text(
              item.patient?.name ?? (isIncome ? 'Direct Income' : 'Clinic Expense'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(item.transaction.createdAt)),
            trailing: Text(
              '${isIncome ? "+" : "-"}\$${item.transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) async {
    final patientsAsync = await ref.read(patientRepositoryProvider).getAllPatients();
    if (!context.mounted) return;

    Patient? selectedPatient;
    var selectedType = 'income';
    final amountController = TextEditingController();

    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'income', label: Text('Income'), icon: Icon(LucideIcons.arrowUpRight)),
                  ButtonSegment(value: 'expense', label: Text('Expense'), icon: Icon(LucideIcons.arrowDownRight)),
                ],
                selected: {selectedType},
                onSelectionChanged: (set) => setState(() => selectedType = set.first),
              ),
              const SizedBox(height: 16),
              if (selectedType == 'income')
                DropdownButtonFormField<Patient>(
                  decoration: const InputDecoration(labelText: 'Patient (Optional)'),
                  items: patientsAsync.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                  onChanged: (val) => setState(() => selectedPatient = val),
                ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount != null) {
                  await ref.read(transactionRepositoryProvider).addTransaction(
                    patientId: selectedPatient?.id,
                    amount: amount,
                    type: selectedType,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }
}
