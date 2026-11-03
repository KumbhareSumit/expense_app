import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/account_provider.dart';
import '../providers/budget_provider.dart';
import '../models/account_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../utils/icon_helper.dart';
import '../utils/notification_helper.dart';
import '../utils/calculator_engine.dart';
import '../widgets/calculator_keyboard.dart';


class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel? transaction;
  final int? initialAccountId;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialAccountId,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _scrollController = ScrollController();

  String _type = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _paymentMode = 'Cash'; // Default payment mode
  int? _selectedAccountId;

  bool _showCalculator = false;
  bool _useSystemKeyboard = false;

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
      _amountController.text =
          CalculatorEngine.formatResult(transaction.amount);
      _noteController.text = transaction.note;
    } else {
      _selectedAccountId = widget.initialAccountId;
    }

    _amountController.addListener(_onAmountChanged);
    _amountFocusNode.addListener(_onAmountFocusChanged);
  }

  void _onAmountChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onAmountFocusChanged() {
    if (_amountFocusNode.hasFocus && !_useSystemKeyboard) {
      _openCalculator();
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountFocusNode.removeListener(_onAmountFocusChanged);
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openCalculator() {
    if (_useSystemKeyboard) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _showCalculator = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          160.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onCalculatorKeyPressed(String key) {
    setState(() {
      _amountController.text = CalculatorEngine.handleKeyPress(
        currentExpression: _amountController.text,
        key: key,
      );
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    });
  }

  void _onCalculatorBackspace() {
    setState(() {
      _amountController.text = CalculatorEngine.handleKeyPress(
        currentExpression: _amountController.text,
        key: '⌫',
      );
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    });
  }

  void _onCalculatorClear() {
    setState(() {
      _amountController.clear();
    });
  }

  void _onCalculatorEquals() {
    setState(() {
      final res = CalculatorEngine.evaluate(_amountController.text);
      if (res != null) {
        _amountController.text = CalculatorEngine.formatResult(res);
        _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length),
        );
      }
    });
  }

  void _onCalculatorDone() {
    final res = CalculatorEngine.evaluate(_amountController.text);
    if (res != null) {
      _amountController.text = CalculatorEngine.formatResult(res);
    }
    setState(() {
      _showCalculator = false;
    });
  }

  void _toggleKeyboardType() {
    setState(() {
      _useSystemKeyboard = !_useSystemKeyboard;
      if (_useSystemKeyboard) {
        _showCalculator = false;
        _amountFocusNode.requestFocus();
      } else {
        FocusScope.of(context).unfocus();
        _showCalculator = true;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_showCalculator) {
      setState(() => _showCalculator = false);
    }
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
    // Evaluate any pending formula before validating
    final evaluated = CalculatorEngine.evaluate(_amountController.text);
    if (evaluated != null) {
      _amountController.text = CalculatorEngine.formatResult(evaluated);
    }

    if (!_formKey.currentState!.validate()) return;

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
    _checkBudgetAlert(transaction);
    Navigator.of(context).pop();
  }

  void _checkBudgetAlert(TransactionModel transaction) {
    if (transaction.type != 'expense') return;

    final budgets = ref.read(budgetProvider);
    final transactions = ref.read(transactionProvider);
    final currency = ref.read(settingsProvider).currencySymbol;

    // 1. Check Overall Budget for transaction month/year
    final overallBudgets = budgets.where(
      (b) =>
          b.month == transaction.date.month &&
          b.year == transaction.date.year &&
          b.categoryId == null,
    );
    if (overallBudgets.isNotEmpty) {
      final budget = overallBudgets.first;
      final currentSpent = transactions
          .where((t) =>
              t.type == 'expense' &&
              t.date.month == transaction.date.month &&
              t.date.year == transaction.date.year &&
              t.id != transaction.id)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalProjected = currentSpent + transaction.amount;
      if (budget.limitAmount > 0 && totalProjected > budget.limitAmount) {
        final exceededBy = totalProjected - budget.limitAmount;
        NotificationHelper.showBudgetAlert(
          title: '⚠️ Monthly Budget Exceeded!',
          body:
              'You have exceeded your monthly budget of $currency${budget.limitAmount.toStringAsFixed(0)} by $currency${exceededBy.toStringAsFixed(0)}.',
        );
        return;
      }
    }

    // 2. Check Category Budget
    final categoryBudgets = budgets.where(
      (b) =>
          b.month == transaction.date.month &&
          b.year == transaction.date.year &&
          b.categoryId == transaction.categoryId,
    );
    if (categoryBudgets.isNotEmpty) {
      final budget = categoryBudgets.first;
      final currentSpent = transactions
          .where((t) =>
              t.type == 'expense' &&
              t.categoryId == transaction.categoryId &&
              t.date.month == transaction.date.month &&
              t.date.year == transaction.date.year &&
              t.id != transaction.id)
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalProjected = currentSpent + transaction.amount;
      if (budget.limitAmount > 0 && totalProjected > budget.limitAmount) {
        final exceededBy = totalProjected - budget.limitAmount;
        NotificationHelper.showBudgetAlert(
          title: '⚠️ Category Budget Exceeded!',
          body:
              'You have exceeded your budget for this category ($currency${budget.limitAmount.toStringAsFixed(0)}) by $currency${exceededBy.toStringAsFixed(0)}.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final filteredCategories = categories
        .where((c) => c.type.trim().toLowerCase() == _type.trim().toLowerCase())
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

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final livePreview =
        CalculatorEngine.evaluatePreview(_amountController.text);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 8,
            ),
            child: Row(
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
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: _showCalculator ? 12 : bottomInset + 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Add type & Account / Wallet placed side-by-side in a single row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Type *',
                              prefixIcon:
                                  Icon(Icons.add_circle_outline, size: 20),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'expense', child: Text('Expense')),
                              DropdownMenuItem(
                                  value: 'income', child: Text('Income')),
                            ],
                            onChanged: _isEditing
                                ? null
                                : (value) => setState(() {
                                    _type = value ?? _type;
                                    _selectedCategoryId = null;
                                  }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            initialValue: selectedAccountId,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Account / Wallet *',
                              prefixIcon: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 20,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            items: accountOptions.values
                                .map(
                                  (account) => DropdownMenuItem<int?>(
                                    value: account.id,
                                    child: Text(
                                      account.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedAccountId = value),
                            validator: (value) =>
                                value == null ? 'Select account' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Category & Date placed side-by-side in a single row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int?>(
                            key: ValueKey('$_type-$_selectedCategoryId'),
                            initialValue: filteredCategories
                                    .any((c) => c.id == _selectedCategoryId)
                                ? _selectedCategoryId
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Category *',
                              prefixIcon:
                                  const Icon(Icons.category_outlined, size: 20),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add_circle_outline,
                                    size: 18),
                                tooltip: 'Add new category',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () =>
                                    _showQuickAddCategoryDialog(context),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            items: filteredCategories
                                .map(
                                  (cat) => DropdownMenuItem<int?>(
                                    value: cat.id,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            color: Color(cat.colorValue)
                                                .withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            IconHelper.getIcon(cat.iconCode),
                                            size: 12,
                                            color: Color(cat.colorValue),
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            cat.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedCategoryId = value),
                            validator: (value) =>
                                value == null ? 'Select category' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(4),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date *',
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(_selectedDate),
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Amount Field with Custom Calculator Keypad Integration
                    TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      readOnly: !_useSystemKeyboard,
                      showCursor: true,
                      onTap: _openCalculator,
                      keyboardType: _useSystemKeyboard
                          ? const TextInputType.numberWithOptions(decimal: true)
                          : TextInputType.none,
                      decoration: InputDecoration(
                        labelText: 'Amount *',
                        prefixText: '$currency ',
                        helperText: livePreview != null
                            ? 'Calculates to: $currency${CalculatorEngine.formatResult(livePreview)}'
                            : null,
                        helperStyle: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_amountController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                tooltip: 'Clear amount',
                                onPressed: () {
                                  setState(() {
                                    _amountController.clear();
                                  });
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                _useSystemKeyboard
                                    ? Icons.calculate_outlined
                                    : Icons.calculate,
                                color: !_useSystemKeyboard
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              tooltip: _useSystemKeyboard
                                  ? 'Switch to Calculator Keypad'
                                  : 'Switch to Standard Keyboard',
                              onPressed: _toggleKeyboardType,
                            ),
                          ],
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter amount';
                        }
                        final amount = CalculatorEngine.evaluate(value);
                        if (amount == null || amount <= 0) {
                          return 'Enter valid amount > 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Note Field
              TextFormField(
                controller: _noteController,
                onTap: () {
                  if (_showCalculator) {
                    setState(() => _showCalculator = false);
                  }
                },
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
    ),
          if (_showCalculator)
            CalculatorKeyboard(
              currencySymbol: currency,
              currentExpression: _amountController.text,
              onKeyPressed: _onCalculatorKeyPressed,
              onBackspace: _onCalculatorBackspace,
              onClear: _onCalculatorClear,
              onEquals: _onCalculatorEquals,
              onDone: _onCalculatorDone,
              onToggleSystemKeyboard: _toggleKeyboardType,
              onClose: () => setState(() => _showCalculator = false),
            ),
        ],
      ),
    );
  }

  void _showQuickAddCategoryDialog(
    BuildContext context, [
    FormFieldState<int?>? formFieldState,
  ]) {
    final nameController = TextEditingController();
    var selectedType = _type;
    var selectedIcon = IconHelper.availableIcons.first;
    var selectedColor = Colors.blue;
    const colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];

    final dialogFormKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'New ${selectedType[0].toUpperCase()}${selectedType.substring(1)} Category',
          ),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Category name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose Icon',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(6),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: IconHelper.availableIcons.length,
                      itemBuilder: (context, idx) {
                        final icon = IconHelper.availableIcons[idx];
                        final isSelected = selectedIcon == icon;
                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              setDialogState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? selectedColor.withValues(alpha: 0.2)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? selectedColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? selectedColor
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose Color',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: colors.map((color) {
                      final isSelected =
                          selectedColor.toARGB32() == color.toARGB32();
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: color,
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: color.computeLuminance() > 0.5
                                      ? Colors.black87
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!dialogFormKey.currentState!.validate()) return;
                final name = nameController.text.trim();
                final newCat = await ref
                    .read(categoryProvider.notifier)
                    .addCategory(
                      CategoryModel(
                        name: name,
                        iconCode: selectedIcon.codePoint,
                        colorValue: selectedColor.toARGB32(),
                        type: selectedType,
                        isCustom: true,
                      ),
                    );
                if (mounted && newCat != null && newCat.id != null) {
                  setState(() => _selectedCategoryId = newCat.id);
                  formFieldState?.didChange(newCat.id);
                }
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
