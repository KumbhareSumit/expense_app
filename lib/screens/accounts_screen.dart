import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
import '../utils/icon_helper.dart';
import '../widgets/fintech_widgets.dart';
import 'debts_screen.dart';
import 'goals_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountState = ref.watch(accountProvider);
    final currency = ref.watch(settingsProvider).currencySymbol;
    final fintech = context.fintech;

    return Scaffold(
      backgroundColor: fintech.background,
      appBar: AppBar(
        backgroundColor: fintech.background,
        elevation: 0,
        title: Text(
          'Accounts & More',
          style: TextStyle(
            color: fintech.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              // 1. Accounts Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: fintech.primaryText,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAccountDialog(context, ref),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: FintechColors.accent, size: 22),
                    tooltip: 'Add account',
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. Accounts List
              if (accountState.accounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: fintech.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: fintech.cardBorder, width: 1),
                  ),
                  child: Text(
                    'Create an account to track Cash, Bank, Card, or Wallet balances.',
                    style: TextStyle(color: fintech.mutedText, fontSize: 13),
                    textAlign: TextAlign.center,
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

              // 3. Planning Section
              Text(
                'Planning',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: fintech.primaryText,
                ),
              ),
              const SizedBox(height: 12),

              _planningCard(
                context,
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFF3EA8FF),
                title: 'Savings Goals',
                subtitle: 'Track money saved for something important',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalsScreen()),
                ),
              ),
              const SizedBox(height: 10),

              _planningCard(
                context,
                icon: Icons.handshake_rounded,
                iconColor: const Color(0xFFFFB020),
                title: 'Debt & Loans',
                subtitle: 'Track money owed to you or by you',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DebtsScreen()),
                ),
              ),
            ],
          ),

          // Pinned bottom primary action button
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: PrimaryBottomButton(
              label: 'Transfer Between Accounts',
              icon: Icons.swap_horiz_rounded,
              onPressed: () => _showTransferDialog(context, ref, accountState.accounts),
            ),
          ),
        ],
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
    final fintech = context.fintech;
    final color = Color(account.colorValue);
    final formattedBalance = NumberFormat('#,##0.00').format(balance.abs());
    final isNegative = balance < 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CategoryIcon(
          icon: IconHelper.getIcon(account.iconCode),
          color: color,
        ),
        title: Text(
          account.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: fintech.primaryText,
          ),
        ),
        subtitle: Text(
          account.type.toUpperCase(),
          style: TextStyle(
            color: fintech.mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          '${isNegative ? '-' : ''}$currency$formattedBalance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: isNegative ? FintechColors.expense : fintech.primaryText,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        onLongPress: () => _confirmDelete(context, ref, account),
      ),
    );
  }

  Widget _planningCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final fintech = context.fintech;
    return Container(
      decoration: BoxDecoration(
        color: fintech.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fintech.cardBorder, width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CategoryIcon(icon: icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: fintech.primaryText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: fintech.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: fintech.mutedText, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref) {
    final fintech = context.fintech;
    final name = TextEditingController();
    final opening = TextEditingController(text: '0');
    var type = 'bank';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                style: TextStyle(color: fintech.primaryText),
                decoration: const InputDecoration(labelText: 'Account name'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: fintech.cardSurface,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  DropdownMenuItem(value: 'cash', child: Text('Cash', style: TextStyle(color: fintech.primaryText))),
                  DropdownMenuItem(value: 'bank', child: Text('Bank', style: TextStyle(color: fintech.primaryText))),
                  DropdownMenuItem(value: 'card', child: Text('Credit Card', style: TextStyle(color: fintech.primaryText))),
                  DropdownMenuItem(value: 'wallet', child: Text('Wallet', style: TextStyle(color: fintech.primaryText))),
                  DropdownMenuItem(value: 'other', child: Text('Other', style: TextStyle(color: fintech.primaryText))),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: opening,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: fintech.primaryText),
                decoration: const InputDecoration(labelText: 'Opening balance'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(opening.text) ?? 0;
                if (name.text.trim().isEmpty) return;
                ref.read(accountProvider.notifier).addAccount(
                      AccountModel(
                        name: name.text.trim(),
                        type: type,
                        openingBalance: amount,
                        colorValue: const Color(0xFF3EE6B0).toARGB32(),
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
    final fintech = context.fintech;
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
          title: const Text('Transfer Money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: from,
                dropdownColor: fintech.cardSurface,
                decoration: const InputDecoration(labelText: 'From account'),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name, style: TextStyle(color: fintech.primaryText)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => from = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: to,
                dropdownColor: fintech.cardSurface,
                decoration: const InputDecoration(labelText: 'To account'),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id,
                        child: Text(a.name, style: TextStyle(color: fintech.primaryText)),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => to = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: fintech.primaryText),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text);
                if (value == null || value <= 0 || from == to) return;
                ref.read(accountProvider.notifier).transfer(
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
    final fintech = context.fintech;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Only delete accounts that no longer contain transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
          ),
          FilledButton(
            onPressed: () {
              ref.read(accountProvider.notifier).deleteAccount(account.id!);
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(backgroundColor: FintechColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
