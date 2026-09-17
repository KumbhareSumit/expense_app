import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';

class DebtsScreen extends ConsumerStatefulWidget {
  const DebtsScreen({super.key});
  @override
  ConsumerState<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends ConsumerState<DebtsScreen> {
  String _type = 'lent';
  @override
  Widget build(BuildContext context) {
    final debts = ref
        .watch(debtProvider)
        .where((debt) => debt.type == _type)
        .toList();
    final currency = ref.watch(settingsProvider).currencySymbol;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt & Loans'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'lent', label: Text('Owed to me')),
                ButtonSegment(value: 'borrowed', label: Text('I owe')),
              ],
              selected: {_type},
              onSelectionChanged: (value) =>
                  setState(() => _type = value.first),
            ),
          ),
        ),
      ),
      body: debts.isEmpty
          ? const Center(child: Text('No debts in this section'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: debts
                  .map((debt) => _debtCard(context, ref, debt, currency))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDebtDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add debt'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }

  Widget _debtCard(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    String currency,
  ) {
    final progress = (debt.paidAmount / debt.totalAmount).clamp(0.0, 1.0);
    final overdue =
        debt.dueDate != null &&
        debt.dueDate!.isBefore(DateTime.now()) &&
        !debt.isSettled;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPaymentDialog(context, ref, debt, currency),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      debt.personName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Debt actions',
                    onSelected: (action) {
                      if (action == 'edit') {
                        _showDebtDialog(context, ref, debt);
                      } else {
                        _confirmDelete(context, ref, debt);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  if (debt.isSettled)
                    Icon(Icons.check_circle, color: context.moneyColors.income)
                  else
                    Icon(
                      Icons.schedule,
                      color: overdue
                          ? context.moneyColors.expense
                          : context.moneyColors.warning,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$currency${(debt.totalAmount - debt.paidAmount).toStringAsFixed(2)} remaining',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: debt.type == 'lent'
                      ? context.moneyColors.income
                      : context.moneyColors.expense,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                color: debt.type == 'lent'
                    ? context.moneyColors.income
                    : context.moneyColors.expense,
              ),
              if (debt.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    overdue
                        ? 'Overdue'
                        : 'Due ${debt.dueDate!.day}/${debt.dueDate!.month}/${debt.dueDate!.year}',
                    style: TextStyle(
                      color: overdue
                          ? context.moneyColors.expense
                          : context.moneyColors.warning,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDebtDialog(BuildContext context, WidgetRef ref, [DebtModel? debt]) {
    final person = TextEditingController(text: debt?.personName ?? '');
    final amount = TextEditingController(
      text: debt == null ? '' : debt.totalAmount.toString(),
    );
    final note = TextEditingController(text: debt?.note ?? '');
    DateTime? dueDate = debt?.dueDate;
    final isEditing = debt != null;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? 'Edit debt or loan' : 'Add debt or loan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: person,
                decoration: const InputDecoration(labelText: 'Person name'),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Total amount'),
              ),
              TextField(
                controller: note,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
                icon: const Icon(Icons.event),
                label: Text(
                  dueDate == null
                      ? 'Optional due date'
                      : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (person.text.trim().isEmpty || value == null || value <= 0)
                  return;
                final updatedDebt = DebtModel(
                  id: debt?.id,
                  personName: person.text.trim(),
                  totalAmount: value,
                  paidAmount: debt?.paidAmount ?? 0,
                  type: debt?.type ?? _type,
                  date: debt?.date ?? DateTime.now(),
                  dueDate: dueDate,
                  note: note.text.trim(),
                  isSettled: debt?.isSettled ?? false,
                );
                if (isEditing) {
                  ref.read(debtProvider.notifier).updateDebt(updatedDebt);
                } else {
                  ref.read(debtProvider.notifier).addDebt(updatedDebt);
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete debt or loan?'),
        content: Text('Delete the record for "${debt.personName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && debt.id != null) {
      await ref.read(debtProvider.notifier).deleteDebt(debt.id!);
    }
  }

  void _showPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    DebtModel debt,
    String currency,
  ) {
    final amount = TextEditingController();
    final note = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add payment for ${debt.personName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '$currency ',
              ),
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(amount.text);
              if (value == null || value <= 0) return;
              ref
                  .read(debtProvider.notifier)
                  .addPayment(debt.id!, value, note.text.trim());
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
