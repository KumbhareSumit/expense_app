import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../utils/icon_helper.dart';
import '../utils/app_theme.dart';
import '../widgets/fintech_widgets.dart';
import 'add_transaction_screen.dart';

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
    final currency = settings.currencySymbol;

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

    final fintech = context.fintech;

    return Scaffold(
      backgroundColor: fintech.background,
      appBar: AppBar(
        backgroundColor: fintech.background,
        elevation: 0,
        title: Text(
          'History',
          style: TextStyle(
            color: fintech.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: fintech.mutedText),
            onPressed: () => _showFilterDialog(context, categories),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: fintech.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: fintech.cardBorder, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: fintech.primaryText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: TextStyle(color: fintech.mutedText, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: fintech.mutedText, size: 20),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: fintech.mutedText, size: 18),
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
          ),

          // 2. Active Filter Tags
          if (_selectedType != null || _selectedCategoryId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  if (_selectedType != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Chip(
                        backgroundColor: fintech.accent.withValues(alpha: 0.15),
                        side: BorderSide(color: fintech.accent, width: 1),
                        label: Text(
                          _selectedType!.toUpperCase(),
                          style: TextStyle(color: fintech.accent, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        deleteIcon: Icon(Icons.close_rounded, size: 14, color: fintech.accent),
                        onDeleted: () => setState(() => _selectedType = null),
                      ),
                    ),
                  if (_selectedCategoryId != null)
                    Chip(
                      backgroundColor: fintech.accent.withValues(alpha: 0.15),
                      side: BorderSide(color: fintech.accent, width: 1),
                      label: Text(
                        categories.firstWhere((c) => c.id == _selectedCategoryId).name,
                        style: TextStyle(color: fintech.accent, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                      deleteIcon: Icon(Icons.close_rounded, size: 14, color: fintech.accent),
                      onDeleted: () => setState(() => _selectedCategoryId = null),
                    ),
                ],
              ),
            ),

          // 3. Transactions Grouped by Date
          Expanded(
            child: sortedDates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: fintech.mutedText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: fintech.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your saved income and expenses will appear here.',
                          style: TextStyle(color: fintech.mutedText, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final dateStr = sortedDates[index];
                      final date = DateTime.parse(dateStr);
                      final items = groupedTransactions[dateStr]!;

                      // Calculate net for the day
                      double dailyNet = 0;
                      for (var item in items) {
                        if (item.type == 'income') {
                          dailyNet += item.amount;
                        } else if (item.type == 'expense') {
                          dailyNet -= item.amount;
                        }
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DateHeader(
                            dateTitle: _formatHeaderDate(date),
                            netAmount: dailyNet,
                            currency: currency,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: fintech.cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: fintech.cardBorder, width: 1),
                            ),
                            child: Column(
                              children: items.map(
                                (t) => _buildTransactionItem(
                                  t,
                                  categories,
                                  currency,
                                ),
                              ).toList(),
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
    return DateFormat('EEE, d MMM').format(date);
  }

  Widget _buildTransactionItem(
    TransactionModel t,
    List<CategoryModel> categories,
    String currency,
  ) {
    final fintech = context.fintech;

    final category = categories.firstWhere(
      (c) => c.id == t.categoryId,
      orElse: () => CategoryModel(
        name: 'Unknown',
        iconCode: Icons.help.codePoint,
        colorValue: Colors.grey.toARGB32(),
        type: t.type,
      ),
    );

    final title = category.name.isNotEmpty ? category.name : (t.note.isNotEmpty ? t.note : 'Transaction');
    final subtitle = t.note.isNotEmpty ? t.note : DateFormat('hh:mm a').format(t.date);

    return Dismissible(
      key: Key(t.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: fintech.expense.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline_rounded, color: fintech.expense),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: fintech.expense),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ref.read(transactionProvider.notifier).deleteTransaction(t.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
      },
      child: TransactionTile(
        title: title,
        subtitle: subtitle,
        amount: t.amount,
        type: t.type,
        categoryColor: Color(category.colorValue),
        icon: IconHelper.getIcon(category.iconCode),
        currency: currency,
        onTap: () => _editTransaction(t),
      ),
    );
  }

  void _editTransaction(TransactionModel transaction) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionScreen(transaction: transaction),
    );
  }

  void _showFilterDialog(BuildContext context, List<CategoryModel> categories) {
    final fintech = context.fintech;

    showModalBottomSheet(
      context: context,
      backgroundColor: fintech.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: fintech.cardBorder, width: 1),
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
                  Text(
                    'Filter Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: fintech.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Type', style: TextStyle(color: fintech.mutedText, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Income'),
                        selected: _selectedType == 'income',
                        selectedColor: fintech.income.withValues(alpha: 0.15),
                        checkmarkColor: fintech.income,
                        labelStyle: TextStyle(
                          color: _selectedType == 'income' ? fintech.income : fintech.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedType = val ? 'income' : null);
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Expense'),
                        selected: _selectedType == 'expense',
                        selectedColor: fintech.expense.withValues(alpha: 0.15),
                        checkmarkColor: fintech.expense,
                        labelStyle: TextStyle(
                          color: _selectedType == 'expense' ? fintech.expense : fintech.primaryText,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedType = val ? 'expense' : null);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: TextStyle(color: fintech.mutedText, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: fintech.inputFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: fintech.cardBorder, width: 1),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: fintech.cardSurface,
                      value: _selectedCategoryId,
                      hint: Text('All Categories', style: TextStyle(color: fintech.mutedText, fontSize: 13)),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Categories', style: TextStyle(color: fintech.primaryText, fontSize: 13)),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name, style: TextStyle(color: fintech.primaryText, fontSize: 13)),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setModalState(() => _selectedCategoryId = val);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryBottomButton(
                    label: 'Apply Filters',
                    onPressed: () => Navigator.pop(context),
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
