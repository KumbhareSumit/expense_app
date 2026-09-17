import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/icon_helper.dart';
import 'add_transaction_screen.dart';
import '../utils/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _searchQuery = '';
  String? _selectedType;
  int? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final categories = ref.watch(categoryProvider);
    final settings = ref.watch(settingsProvider);

    final filteredTransactions = transactions.where((t) {
      final matchesSearch = t.note.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesType = _selectedType == null || t.type == _selectedType;
      final matchesCategory =
          _selectedCategoryId == null || t.categoryId == _selectedCategoryId;
      return matchesSearch && matchesType && matchesCategory;
    }).toList();

    // Group by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var t in filteredTransactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(t.date);
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(t);
    }

    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context, categories),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_selectedType != null || _selectedCategoryId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedType != null)
                    Chip(
                      label: Text('Type: ${_selectedType!.toUpperCase()}'),
                      onDeleted: () => setState(() => _selectedType = null),
                    ),
                  if (_selectedCategoryId != null)
                    Chip(
                      label: Text(
                        'Category: ${categories.firstWhere((c) => c.id == _selectedCategoryId).name}',
                      ),
                      onDeleted: () =>
                          setState(() => _selectedCategoryId = null),
                    ),
                ],
              ),
            ),
          Expanded(
            child: sortedDates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 72,
                          color: context.moneyColors.muted.withValues(
                            alpha: .55,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('No transactions found'),
                        const SizedBox(height: 8),
                        Text(
                          'Your saved income and expenses will appear here.',
                          style: TextStyle(color: context.moneyColors.muted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateStr = sortedDates[index];
                      final date = DateTime.parse(dateStr);
                      final items = groupedTransactions[dateStr]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              _formatHeaderDate(date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: context.moneyColors.muted,
                              ),
                            ),
                          ),
                          ...items.map(
                            (t) => _buildTransactionItem(
                              t,
                              categories,
                              settings.currencySymbol,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatHeaderDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('EEE, dd MMM yyyy').format(date);
  }

  Widget _buildTransactionItem(
    TransactionModel t,
    List<CategoryModel> categories,
    String currency,
  ) {
    final category = categories.firstWhere(
      (c) => c.id == t.categoryId,
      orElse: () => CategoryModel(
        name: 'Unknown',
        iconCode: Icons.help.codePoint,
        colorValue: Colors.grey.value,
        type: 'expense',
      ),
    );
    final isIncome = t.type == 'income';
    final isInvestment = t.type == 'investment';

    return Dismissible(
      key: Key(t.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: context.moneyColors.expense,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text(
              'Are you sure you want to delete this transaction?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: context.moneyColors.expense),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(transactionProvider.notifier).deleteTransaction(t.id!);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transaction deleted')));
      },
      child: ListTile(
        onTap: () => _editTransaction(t),
        leading: CircleAvatar(
          backgroundColor: Color(category.colorValue).withOpacity(0.2),
          child: Icon(
            IconHelper.getIcon(category.iconCode),
            color: Color(category.colorValue),
          ),
        ),
        title: Text(category.name),
        subtitle: t.note.isNotEmpty ? Text(t.note) : null,
        trailing: Text(
          '${isIncome
              ? '+'
              : isInvestment
              ? ''
              : '-'}$currency${t.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome
                ? context.moneyColors.income
                : isInvestment
                ? Colors.teal
                : context.moneyColors.expense,
          ),
        ),
      ),
    );
  }

  void _editTransaction(TransactionModel transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTransactionScreen(transaction: transaction),
    );
  }

  void _showFilterDialog(BuildContext context, List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Transactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Type'),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Income'),
                        selected: _selectedType == 'income',
                        onSelected: (val) {
                          setModalState(
                            () => _selectedType = val ? 'income' : null,
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Expense'),
                        selected: _selectedType == 'expense',
                        onSelected: (val) {
                          setModalState(
                            () => _selectedType = val ? 'expense' : null,
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Investment'),
                        selected: _selectedType == 'investment',
                        onSelected: (val) {
                          setModalState(
                            () => _selectedType = val ? 'investment' : null,
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Category'),
                  DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedCategoryId,
                    hint: const Text('Select Category'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() => _selectedCategoryId = val);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
