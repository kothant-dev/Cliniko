import 'package:cliniko/core/db/database.dart';
import 'package:cliniko/core/theme/app_theme.dart';
import 'package:cliniko/core/widgets/glass_card.dart';
import 'package:cliniko/features/inventory/data/inventory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

final inventoryStreamProvider = StreamProvider<List<Medicine>>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchAllMedicines();
});

final lowStockCountProvider = StreamProvider<int>((ref) {
  return ref.watch(inventoryRepositoryProvider).watchLowStockCount(10);
});

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryAsync = ref.watch(inventoryStreamProvider);

    return Scaffold(
      body: inventoryAsync.when(
        data: (medicines) => medicines.isEmpty
            ? _buildEmptyState(context)
            : _buildMedicineList(context, ref, medicines),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMedicineDialog(context, ref),
        label: const Text('Add Medicine'),
        icon: const Icon(LucideIcons.packagePlus),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.package, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          const Text('No medicines in stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add items to your pharmacy inventory'),
        ],
      ),
    );
  }

  Widget _buildMedicineList(BuildContext context, WidgetRef ref, List<Medicine> medicines) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.space16),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        final medicine = medicines[index];
        final isLowStock = medicine.stockQuantity < 10;
        final isNearExpiry = medicine.expiryDate != null && 
            medicine.expiryDate!.difference(DateTime.now()).inDays < 30;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.space12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.space16, vertical: AppTheme.space8),
              leading: CircleAvatar(
                backgroundColor: isLowStock 
                    ? Colors.orange.withValues(alpha: 0.1) 
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  LucideIcons.pill, 
                  color: isLowStock ? Colors.orange : Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: Text(medicine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock: ${medicine.stockQuantity} | Batch: ${medicine.batchNumber ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).disabledColor),
                  ),
                  if (medicine.expiryDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(LucideIcons.calendar, size: 12, color: isNearExpiry ? Colors.red : Theme.of(context).disabledColor),
                          const SizedBox(width: 4),
                          Text(
                            'Exp: ${DateFormat('MMM dd, yyyy').format(medicine.expiryDate!)}',
                            style: TextStyle(
                              color: isNearExpiry ? Colors.red : Theme.of(context).disabledColor,
                              fontSize: 11,
                              fontWeight: isNearExpiry ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${medicine.unitPrice.toStringAsFixed(2)}', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LOW STOCK', 
                        style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              onTap: () => _showUpdateStockDialog(context, ref, medicine),
            ),
          ),
        );
      },
    );
  }

  void _showAddMedicineDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final batchController = TextEditingController();
    final stockController = TextEditingController(text: '0');
    final priceController = TextEditingController(text: '0.0');
    DateTime? selectedExpiry;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Medicine Name')),
                TextField(controller: batchController, decoration: const InputDecoration(labelText: 'Batch Number')),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Initial Stock'), keyboardType: TextInputType.number),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Unit Price'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                ListTile(
                  title: const Text('Expiry Date'),
                  trailing: Text(selectedExpiry == null ? 'Select' : DateFormat('yyyy-MM-dd').format(selectedExpiry!)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (date != null) setState(() => selectedExpiry = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await ref.read(inventoryRepositoryProvider).addMedicine(
                    name: nameController.text,
                    batchNumber: batchController.text,
                    stockQuantity: int.tryParse(stockController.text) ?? 0,
                    unitPrice: double.tryParse(priceController.text) ?? 0.0,
                    expiryDate: selectedExpiry,
                  );
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, WidgetRef ref, Medicine medicine) {
    final stockController = TextEditingController(text: medicine.stockQuantity.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${medicine.name}'),
        content: TextField(
          controller: stockController,
          decoration: const InputDecoration(labelText: 'New Stock Level'),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null) {
                await ref.read(inventoryRepositoryProvider).updateMedicine(
                  medicine.copyWith(stockQuantity: newStock),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
