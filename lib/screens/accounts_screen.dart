import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../utils/icon_helper.dart';
import 'debts_screen.dart';
import 'goals_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final currency = ref.watch(settingsProvider).currencySymbol;
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts & More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your accounts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => _showAccountDialog(context, ref),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add account',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (accountState.accounts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Create an account to track Cash, Bank, Card, or Wallet balances.',
                ),
              ),
            )
          else
            ...accountState.accounts.map(
              (account) => _accountCard(
                context,
                ref,
                account,
                accountState.balances[account.id] ?? account.openingBalance,
                currency,
              ),
            ),
          const SizedBox(height: 24),
          Text('Planning', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              minVerticalPadding: 12,
              leading: const CircleAvatar(child: Icon(Icons.flag_outlined)),
              title: Text(
                'Savings Goals',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: const Text(
                'Track money saved for something important',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GoalsScreen()),
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              minVerticalPadding: 12,
              leading: const CircleAvatar(
                child: Icon(Icons.handshake_outlined),
              ),
              title: Text(
                'Debt & Loans',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: const Text('Track money owed to you or by you'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DebtsScreen()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showTransferDialog(context, ref, accountState.accounts),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Transfer'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedPadding: const EdgeInsets.symmetric(horizontal: 18),
      ),
    );
  }

  Widget _accountCard(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
    double balance,
    String currency,
  ) {
    final color = Color(account.colorValue);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: .15),
          child: Icon(IconHelper.getIcon(account.iconCode), color: color),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(account.type.toUpperCase()),
        trailing: Text(
          '$currency${balance.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: balance >= 0
                ? context.moneyColors.income
                : context.moneyColors.expense,
          ),
        ),
        onLongPress: () => _confirmDelete(context, ref, account),
      ),
    );
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref) {
    final name = TextEditingController();
    final opening = TextEditingController(text: '0');
    var type = 'bank';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Account name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank', child: Text('Bank')),
                  DropdownMenuItem(value: 'card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'wallet', child: Text('Wallet')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: opening,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Opening balance'),
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
                final amount = double.tryParse(opening.text) ?? 0;
                if (name.text.trim().isEmpty) return;
                ref
                    .read(accountProvider.notifier)
                    .addAccount(
                      AccountModel(
                        name: name.text.trim(),
                        type: type,
                        openingBalance: amount,
                        colorValue: Colors.teal.value,
                        iconCode: Icons.account_balance_wallet.codePoint,
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog(
    BuildContext context,
    WidgetRef ref,
    List<AccountModel> accounts,
  ) {
    if (accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least two accounts to transfer money.'),
        ),
      );
      return;
    }
    final amount = TextEditingController();
    var from = accounts.first.id!;
    var to = accounts[1].id!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Transfer money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: from,
                decoration: const InputDecoration(labelText: 'From account'),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => from = value!),
              ),
              DropdownButtonFormField<int>(
                initialValue: to,
                decoration: const InputDecoration(labelText: 'To account'),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(value: a.id, child: Text(a.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => to = value!),
              ),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Amount'),
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
                if (value == null || value <= 0 || from == to) return;
                ref
                    .read(accountProvider.notifier)
                    .transfer(
                      fromAccountId: from,
                      toAccountId: to,
                      amount: value,
                      date: DateTime.now(),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Transfer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'Only delete accounts that no longer contain transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(accountProvider.notifier).deleteAccount(account.id!);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
