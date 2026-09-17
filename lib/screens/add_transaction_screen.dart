import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/debt_provider.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';
import '../models/goal_model.dart';
import '../models/debt_model.dart';
import '../utils/icon_helper.dart';

class SplitPerson {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }
}

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
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Cash'; // Default payment mode
  int? _selectedAccountId;
  String _debtType = 'lent';

  bool _isSplit = false;
  final List<SplitPerson> _splitPersons = [];

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
    _nameController.dispose();
    _noteController.dispose();
    for (var p in _splitPersons) {
      p.dispose();
    }
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

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_type == 'goal') {
      ref
          .read(goalProvider.notifier)
          .addGoal(
            GoalModel(
              name: _nameController.text.trim(),
              targetAmount: amount,
              currentAmount: 0,
              deadline: null,
              colorValue: Colors.teal.value,
              iconCode: Icons.flag.codePoint,
            ),
          );
      Navigator.of(context).pop();
      return;
    }
    if (_type == 'debt') {
      ref
          .read(debtProvider.notifier)
          .addDebt(
            DebtModel(
              personName: _nameController.text.trim(),
              totalAmount: amount,
              type: _debtType,
              date: DateTime.now(),
              note: _noteController.text.trim(),
            ),
          );
      Navigator.of(context).pop();
      return;
    }

    double finalTransactionAmount = amount;
    if (_isSplit && _type == 'expense' && !_isEditing) {
      double friendsTotal = 0;
      for (var p in _splitPersons) {
        if (p.nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter names for all friends')));
          return;
        }
        final amt = double.tryParse(p.amountController.text) ?? 0;
        if (amt <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid split amounts')));
          return;
        }
        friendsTotal += amt;
      }
      
      final myShare = amount - friendsTotal;
      if (myShare < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Friend amounts cannot exceed total amount')));
        return;
      }
      
      finalTransactionAmount = myShare;
      
      for (var p in _splitPersons) {
        final amt = double.tryParse(p.amountController.text) ?? 0;
        ref.read(debtProvider.notifier).addDebt(
          DebtModel(
            personName: p.nameController.text.trim(),
            totalAmount: amt,
            type: 'lent',
            date: _selectedDate,
            note: _noteController.text.trim().isEmpty ? 'Split Expense' : 'Split: ${_noteController.text.trim()}',
          ),
        );
      }
    }

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      amount: finalTransactionAmount,
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
    final isTransaction =
        _type == 'expense' || _type == 'income' || _type == 'investment';
    final isGoal = _type == 'goal';
    final isDebt = _type == 'debt';
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

              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Add type *',
                  prefixIcon: Icon(Icons.add_circle_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(
                    value: 'investment',
                    child: Text('Investment'),
                  ),
                  DropdownMenuItem(value: 'goal', child: Text('Savings Goal')),
                  DropdownMenuItem(value: 'debt', child: Text('Debt / Loan')),
                ],
                onChanged: _isEditing
                    ? null
                    : (value) => setState(() {
                        _type = value ?? _type;
                        _selectedCategoryId = null;
                      }),
              ),
              const SizedBox(height: 20),

              if (isTransaction)
                DropdownButtonFormField<int?>(
                  initialValue: selectedAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Account / Wallet *',
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
                  validator: (value) =>
                      value == null ? 'Select an account or wallet' : null,
                ),
              if (isTransaction) const SizedBox(height: 20),

              if (isGoal || isDebt)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: isGoal ? 'Goal name *' : 'Person name *',
                    prefixIcon: Icon(
                      isGoal ? Icons.flag_outlined : Icons.person_outline,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if ((isGoal || isDebt) &&
                        (value == null || value.trim().isEmpty)) {
                      return isGoal
                          ? 'Enter a goal name'
                          : 'Enter a person name';
                    }
                    return null;
                  },
                ),
              if (isGoal || isDebt) const SizedBox(height: 20),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Amount *',
                  prefixText: '$currency ',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  if (_isSplit) setState(() {});
                },
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0)
                    return 'Enter valid amount > 0';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (!_isEditing && _type == 'expense')
                SwitchListTile(
                  title: const Text('Split with others', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Add friends to split this bill'),
                  value: _isSplit,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _isSplit = value;
                      if (_isSplit && _splitPersons.isEmpty) {
                        _splitPersons.add(SplitPerson());
                      }
                    });
                  },
                ),
              
              if (_isSplit && _type == 'expense' && !_isEditing) ...[
                const SizedBox(height: 10),
                ..._splitPersons.asMap().entries.map((entry) {
                  final index = entry.key;
                  final person = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: person.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Friend Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: person.amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixText: '$currency ',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              person.dispose();
                              _splitPersons.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Person'),
                      onPressed: () {
                        setState(() {
                          _splitPersons.add(SplitPerson());
                        });
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calculate),
                      label: const Text('Split Equally'),
                      onPressed: () {
                        final total = double.tryParse(_amountController.text) ?? 0;
                        if (total > 0 && _splitPersons.isNotEmpty) {
                          final share = total / (_splitPersons.length + 1);
                          setState(() {
                            for (var p in _splitPersons) {
                              p.amountController.text = share.toStringAsFixed(2);
                            }
                          });
                        }
                      },
                    ),
                  ],
                ),
                Builder(
                  builder: (context) {
                    final total = double.tryParse(_amountController.text) ?? 0;
                    double friendsTotal = 0;
                    for (var p in _splitPersons) {
                      friendsTotal += double.tryParse(p.amountController.text) ?? 0;
                    }
                    final myShare = total - friendsTotal;
                    final isError = myShare < 0;
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isError ? Colors.red.withValues(alpha: .1) : Colors.green.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isError ? Colors.red : Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Share:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isError ? Colors.red : Colors.green,
                              ),
                            ),
                            Text(
                              '$currency ${myShare.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isError ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ],

              if (isDebt)
                DropdownButtonFormField<String>(
                  initialValue: _debtType,
                  decoration: const InputDecoration(
                    labelText: 'Debt type',
                    prefixIcon: Icon(Icons.swap_horiz),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'lent', child: Text('Owed to me')),
                    DropdownMenuItem(value: 'borrowed', child: Text('I owe')),
                  ],
                  onChanged: (value) =>
                      setState(() => _debtType = value ?? _debtType),
                ),
              if (isDebt) const SizedBox(height: 20),

              // Category Selector
              if (isTransaction) ...[
                FormField<int>(
                  key: ValueKey(_type),
                  initialValue: _selectedCategoryId,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category *',
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
                                    final isSelected =
                                        _selectedCategoryId == cat.id;
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        setState(
                                            () => _selectedCategoryId = cat.id);
                                        state.didChange(cat.id);
                                      },
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
                                                      color: theme
                                                          .colorScheme.onSurface,
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
                        if (state.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              state.errorText!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Date Picker
              if (isTransaction)
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
              if (isTransaction) const SizedBox(height: 20),

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
                    _isEditing
                        ? 'Update Transaction'
                        : isGoal
                        ? 'Save Savings Goal'
                        : isDebt
                        ? 'Save Debt / Loan'
                        : 'Save Transaction',
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
