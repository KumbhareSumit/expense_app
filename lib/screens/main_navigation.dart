import 'package:flutter/material.dart';

import 'analysis_screen.dart';
import 'accounts_screen.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import '../utils/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalysisScreen(),
    HistoryScreen(),
    BudgetScreen(),
    AccountsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FintechColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: FintechColors.navBg,
          border: Border(
            top: BorderSide(color: FintechColors.navBorder, width: 1.0),
          ),
        ),
        child: NavigationBar(
          backgroundColor: FintechColors.navBg,
          elevation: 0,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.grid_view_rounded),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'Analysis',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_rounded),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_rounded),
              selectedIcon: Icon(Icons.credit_card_rounded),
              label: 'Accounts',
            ),
          ],
        ),
      ),
    );
  }
}
