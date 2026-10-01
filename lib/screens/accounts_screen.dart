import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/account_model.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_theme.dart';
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

  static const List<Color> _cardColorPresets = [
    Color(0xFF312E81), // Deep Indigo Metal
    Color(0xFF047857), // Emerald Fintech
    Color(0xFF18181B), // Obsidian Carbon
    Color(0xFF9F1239), // Crimson Luxury
    Color(0xFF1D4ED8), // Royal Sapphire
    Color(0xFFD97706), // Amber Gold
    Color(0xFF0F766E), // Midnight Teal
    Color(0xFF475569), // Titanium Slate
  ];

  Widget _accountCard(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
    double balance,
    String currency,
  ) {
    final fintech = context.fintech;
    final color = Color(account.colorValue != 0 ? account.colorValue : 0xFF312E81);
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                HSLColor.fromColor(color)
                    .withLightness((HSLColor.fromColor(color).lightness + 0.12).clamp(0.0, 1.0))
                    .toColor(),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getAccountIcon(account.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          account.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
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
            letterSpacing: 0.4,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isNegative ? '-' : ''}$currency$formattedBalance',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: isNegative ? FintechColors.expense : fintech.primaryText,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: fintech.mutedText, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: fintech.cardSurface,
              elevation: 4,
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAccountDialog(context, ref, account);
                } else if (value == 'delete') {
                  _confirmDelete(context, ref, account);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: fintech.primaryText),
                      const SizedBox(width: 10),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: fintech.primaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline_rounded, size: 18, color: FintechColors.expense),
                      SizedBox(width: 10),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: FintechColors.expense,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => _showEditAccountDialog(context, ref, account),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bank':
        return Icons.account_balance_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
        return Icons.payments_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
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

  Widget _buildMiniCardPreview({
    required String name,
    required String type,
    required double balance,
    required Color color,
    required String currency,
  }) {
    final hsl = HSLColor.fromColor(color);
    final darker = hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
    final lighter = hsl.withLightness((hsl.lightness + 0.14).clamp(0.0, 1.0)).toColor();
    final isLight = color.computeLuminance() > 0.52;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final secondaryTextColor = isLight ? const Color(0xFF334155) : Colors.white.withValues(alpha: 0.85);

    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darker, color, lighter],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getAccountIcon(type), size: 14, color: textColor),
                  const SizedBox(width: 6),
                  Text(
                    name.isEmpty ? 'ACCOUNT NAME' : name.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                '•••• 0001',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Mini Metallic Chip
              Container(
                width: 20,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFE082), Color(0xFFD4AF37)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.amber.shade700, width: 0.5),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.contactless_rounded, size: 13, color: secondaryTextColor.withValues(alpha: 0.8)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currency ${NumberFormat('#,##0.00').format(balance)}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAccountDialog(BuildContext context, WidgetRef ref) {
    final fintech = context.fintech;
    final currency = ref.read(settingsProvider).currencySymbol;
    final name = TextEditingController();
    final opening = TextEditingController(text: '0');
    var type = 'bank';
    var selectedColor = _cardColorPresets[0];

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniCardPreview(
                  name: name.text.trim(),
                  type: type,
                  balance: double.tryParse(opening.text) ?? 0,
                  color: selectedColor,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  style: TextStyle(color: fintech.primaryText),
                  decoration: const InputDecoration(labelText: 'Account name'),
                  onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                Text(
                  'Card Color',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: fintech.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _cardColorPresets.map((c) {
                    final isSelected = c.toARGB32() == selectedColor.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
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
                        colorValue: selectedColor.toARGB32(),
                        iconCode: _getAccountIcon(type).codePoint,
                        createdAt: DateTime.now(),
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

  void _showEditAccountDialog(
    BuildContext context,
    WidgetRef ref,
    AccountModel account,
  ) {
    final fintech = context.fintech;
    final currency = ref.read(settingsProvider).currencySymbol;
    final name = TextEditingController(text: account.name);
    final opening = TextEditingController(
      text: account.openingBalance == 0 ? '0' : account.openingBalance.toStringAsFixed(2),
    );
    var type = account.type;
    var selectedColor = Color(account.colorValue != 0 ? account.colorValue : _cardColorPresets[0].toARGB32());

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Account Card'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMiniCardPreview(
                  name: name.text.trim(),
                  type: type,
                  balance: double.tryParse(opening.text) ?? account.openingBalance,
                  color: selectedColor,
                  currency: currency,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: name,
                  style: TextStyle(color: fintech.primaryText),
                  decoration: const InputDecoration(labelText: 'Account name'),
                  onChanged: (_) => setState(() {}),
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
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                Text(
                  'Card Color',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: fintech.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _cardColorPresets.map((c) {
                    final isSelected = c.toARGB32() == selectedColor.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: c.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: fintech.mutedText)),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(opening.text) ?? account.openingBalance;
                if (name.text.trim().isEmpty) return;
                ref.read(accountProvider.notifier).updateAccount(
                      account.copyWith(
                        name: name.text.trim(),
                        type: type,
                        openingBalance: amount,
                        colorValue: selectedColor.toARGB32(),
                        iconCode: _getAccountIcon(type).codePoint,
                      ),
                    );
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
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
