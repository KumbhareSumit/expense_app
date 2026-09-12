import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../database/db_helper.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'categories_screen.dart';
import 'budget_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme Mode'),
            subtitle: Text(_themeModeToString(settings.themeMode)),
            onTap: () =>
                _showThemeDialog(context, settings.themeMode, settingsNotifier),
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('Currency Symbol'),
            subtitle: Text(settings.currencySymbol),
            onTap: () => _showCurrencyDialog(
              context,
              settings.currencySymbol,
              settingsNotifier,
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Data Management'),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Manage Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoriesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Set Monthly Budget'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            subtitle: const Text('Export transactions and categories to JSON'),
            onTap: () => _backupData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            subtitle: const Text('Import data from a backup JSON file'),
            onTap: () => _restoreData(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: scheme.error),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: scheme.error),
            ),
            onTap: () => _showClearDataDialog(context, ref),
          ),
          const Divider(),
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System Default';
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
    }
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeMode currentMode,
    SettingsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeToString(mode)),
              value: mode,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  notifier.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog(
    BuildContext context,
    String currentSymbol,
    SettingsNotifier notifier,
  ) {
    final List<String> currencies = [
      '4',
      '\u20AC',
      '\u00A3',
      '\u00A5',
      '\u20B9',
      '\u20BD',
      '\u20A9',
    ];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
            ),
            itemCount: currencies.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  notifier.setCurrency(currencies[index]);
                  Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    currencies[index],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: currentSymbol == currencies[index]
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: currentSymbol == currencies[index]
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    try {
      final transactions = ref.read(transactionProvider);
      final categories = ref.read(categoryProvider);

      final data = {
        'transactions': transactions.map((t) => t.toMap()).toList(),
        'categories': categories.map((c) => c.toMap()).toList(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup.json');
      await file.writeAsString(jsonString);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Backup saved to: ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Backup failed: $e')));
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/expense_backup.json');

      if (!await file.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No backup file found at the expected location.'),
          ),
        );
        return;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final categoriesJson = data['categories'] as List<dynamic>;
      final transactionsJson = data['transactions'] as List<dynamic>;

      final categories = categoriesJson
          .map((c) => CategoryModel.fromMap(c))
          .toList();
      final transactions = transactionsJson
          .map((t) => TransactionModel.fromMap(t))
          .toList();

      await DBHelper().restoreData(categories, transactions);

      // Invalidate providers to reload data
      ref.invalidate(transactionProvider);
      ref.invalidate(categoryProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data restored successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Restore failed: $e')));
    }
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all transactions and custom categories. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DBHelper().clearAllData();
              ref.invalidate(transactionProvider);
              ref.invalidate(categoryProvider);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
