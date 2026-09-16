import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../utils/icon_helper.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Cash'; // Default payment mode
  int? _selectedAccountId;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _selectedCategoryId = transaction.categoryId;
      _selectedDate = transaction.date;
      _paymentMode = transaction.paymentMode;
      _selectedAccountId = transaction.accountId;
      _amountController.text = transaction.amount.toString();
      _noteController.text = transaction.note;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0;

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      amount: amount,
      type: _type,
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      note: _noteController.text,
      paymentMode: _paymentMode,
      accountId:
          _selectedAccountId ??
          ref.read(accountProvider).accounts.firstOrNull?.id,
    );

    if (_isEditing) {
      ref.read(transactionProvider.notifier).updateTransaction(transaction);
    } else {
      ref.read(transactionProvider.notifier).addTransaction(transaction);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final filteredCategories = categories
        .where((c) => c.type == _type)
        .toList();
    final settings = ref.watch(settingsProvider);
    final accountState = ref.watch(accountProvider);
    final currency = settings.currencySymbol;
    final accountOptions = <int, AccountModel>{
      for (final account in accountState.accounts)
        if (account.id != null) account.id!: account,
    };
    final selectedAccountId = accountOptions.containsKey(_selectedAccountId)
        ? _selectedAccountId
        : accountOptions.keys.firstOrNull;

    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Transaction' : 'Add Transaction',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<int?>(
                initialValue: selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account / Wallet',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                ),
                items: accountOptions.values
                    .map(
                      (account) => DropdownMenuItem<int?>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedAccountId = value),
              ),
              const SizedBox(height: 20),

              // Type Selector
              Center(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'expense',
                      label: Text('Expense'),
                      icon: Icon(Icons.remove_circle_outline),
                    ),
                    ButtonSegment(
                      value: 'income',
                      label: Text('Income'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _type = newSelection.first;
                      _selectedCategoryId =
                          null; // Reset category when type changes
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '$currency ',
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0)
                    return 'Enter valid amount > 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Selector
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: filteredCategories.isEmpty
                    ? const Center(
                        child: Text('No categories found for this type'),
                      )
                    : GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final cat = filteredCategories[index];
                          final isSelected = _selectedCategoryId == cat.id;
                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () =>
                                setState(() => _selectedCategoryId = cat.id),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(cat.colorValue)
                                        : Color(cat.colorValue)
                                              .withValues(alpha: .1),
                                    shape: BoxShape.circle,
                                    border: isSelected
                                        ? Border.all(
                                            color: theme.colorScheme.onSurface,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    IconHelper.getIcon(cat.iconCode),
                                    color: isSelected
                                        ? (Color(cat.colorValue)
                                                      .computeLuminance() >
                                                  .5
                                              ? Colors.black87
                                              : Colors.white)
                                        : Color(cat.colorValue),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _submitData,
                  child: Text(
                    _isEditing ? 'Update Transaction' : 'Save Transaction',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
