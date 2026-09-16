import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/account_model.dart';
import '../models/goal_model.dart';
import '../models/debt_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconCode INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        type TEXT NOT NULL,
        isCustom INTEGER NOT NULL
      )
    ''');

    // Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        paymentMode TEXT NOT NULL,
        isRecurring INTEGER NOT NULL,
        accountId INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Budgets Table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        categoryId INTEGER,
        limitAmount REAL NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Pre-populate Categories
    await _prePopulateCategories(db);
    await _createFeatureTables(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'CREATE TABLE accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, openingBalance REAL NOT NULL, colorValue INTEGER NOT NULL, iconCode INTEGER NOT NULL)',
      );
      await db.execute('ALTER TABLE transactions ADD COLUMN accountId INTEGER');
      final accountId = await db.insert('accounts', {
        'name': 'Cash',
        'type': 'cash',
        'openingBalance': 0.0,
        'colorValue': 0xFF176B5B,
        'iconCode': 0xE8B0,
      });
      await db.update('transactions', {
        'accountId': accountId,
      }, where: 'accountId IS NULL');
      await _createFeatureTables(db);
    }
    if (oldVersion < 3) {
      await _ensureBankAccount(db);
    }
  }

  Future<void> _createFeatureTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, openingBalance REAL NOT NULL, colorValue INTEGER NOT NULL, iconCode INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS transfers (id INTEGER PRIMARY KEY AUTOINCREMENT, fromAccountId INTEGER NOT NULL, toAccountId INTEGER NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, note TEXT, FOREIGN KEY (fromAccountId) REFERENCES accounts(id) ON DELETE CASCADE, FOREIGN KEY (toAccountId) REFERENCES accounts(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, targetAmount REAL NOT NULL, currentAmount REAL NOT NULL, deadline TEXT, colorValue INTEGER NOT NULL, iconCode INTEGER NOT NULL, isCompleted INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS goal_contributions (id INTEGER PRIMARY KEY AUTOINCREMENT, goalId INTEGER NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, note TEXT, FOREIGN KEY (goalId) REFERENCES goals(id) ON DELETE CASCADE)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS debts (id INTEGER PRIMARY KEY AUTOINCREMENT, personName TEXT NOT NULL, totalAmount REAL NOT NULL, paidAmount REAL NOT NULL, type TEXT NOT NULL, date TEXT NOT NULL, dueDate TEXT, note TEXT, isSettled INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS debt_payments (id INTEGER PRIMARY KEY AUTOINCREMENT, debtId INTEGER NOT NULL, amount REAL NOT NULL, date TEXT NOT NULL, note TEXT, FOREIGN KEY (debtId) REFERENCES debts(id) ON DELETE CASCADE)',
    );
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM accounts'),
        ) ??
        0;
    if (count == 0) {
      await db.insert('accounts', {
        'name': 'Cash',
        'type': 'cash',
        'openingBalance': 0.0,
        'colorValue': 0xFF176B5B,
        'iconCode': 0xE8B0,
      });
    }
    await _ensureBankAccount(db);
  }

  Future<void> _ensureBankAccount(Database db) async {
    final bankCount =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM accounts WHERE type = 'bank'"),
        ) ??
        0;
    if (bankCount == 0) {
      await db.insert('accounts', {
        'name': 'Bank',
        'type': 'bank',
        'openingBalance': 0.0,
        'colorValue': 0xFF1565C0,
        'iconCode': 0xE84F,
      });
    }
  }

  Future<void> _prePopulateCategories(Database db) async {
    final List<CategoryModel> defaultCategories = [
      CategoryModel(
        name: 'Food',
        iconCode: 58746,
        colorValue: 0xFFF44336,
        type: 'expense',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Transport',
        iconCode: 58673,
        colorValue: 0xFF2196F3,
        type: 'expense',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Shopping',
        iconCode: 59105,
        colorValue: 0xFFFF9800,
        type: 'expense',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Entertainment',
        iconCode: 58914,
        colorValue: 0xFF9C27B0,
        type: 'expense',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Health',
        iconCode: 58683,
        colorValue: 0xFF4CAF50,
        type: 'expense',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Salary',
        iconCode: 57895,
        colorValue: 0xFF4CAF50,
        type: 'income',
        isCustom: false,
      ),
      CategoryModel(
        name: 'Investment',
        iconCode: 58941,
        colorValue: 0xFF009688,
        type: 'income',
        isCustom: false,
      ),
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // --- CRUD Operations for Categories ---
  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => CategoryModel.fromMap(maps[i]));
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Operations for Transactions ---
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // --- CRUD Operations for Budgets ---
  Future<int> insertBudget(BudgetModel budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<BudgetModel>> getAllBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('budgets');
    return List.generate(maps.length, (i) => BudgetModel.fromMap(maps[i]));
  }

  Future<int> updateBudget(BudgetModel budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertAccount(AccountModel account) async =>
      (await database).insert('accounts', account.toMap());
  Future<List<AccountModel>> getAllAccounts() async => (await database)
      .query('accounts')
      .then((rows) => rows.map(AccountModel.fromMap).toList());
  Future<int> updateAccount(AccountModel account) async =>
      (await database).update(
        'accounts',
        account.toMap(),
        where: 'id = ?',
        whereArgs: [account.id],
      );
  Future<int> deleteAccount(int id) async =>
      (await database).delete('accounts', where: 'id = ?', whereArgs: [id]);

  Future<Map<int, double>> getAccountBalances() async {
    final db = await database;
    final balances = <int, double>{};
    for (final row in await db.query('accounts')) {
      final id = row['id'] as int;
      final opening = (row['openingBalance'] as num).toDouble();
      Future<double> sum(String sql, List<Object?> args) async {
        final result = await db.rawQuery(sql, args);
        return ((result.first.values.first as num?) ?? 0).toDouble();
      }

      final income = await sum(
        'SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE accountId = ? AND type = ?',
        [id, 'income'],
      );
      final expense = await sum(
        'SELECT COALESCE(SUM(amount), 0) FROM transactions WHERE accountId = ? AND type = ?',
        [id, 'expense'],
      );
      final incoming = await sum(
        'SELECT COALESCE(SUM(amount), 0) FROM transfers WHERE toAccountId = ?',
        [id],
      );
      final outgoing = await sum(
        'SELECT COALESCE(SUM(amount), 0) FROM transfers WHERE fromAccountId = ?',
        [id],
      );
      balances[id] = opening + income - expense + incoming - outgoing;
    }
    return balances;
  }

  Future<int> insertTransfer(Map<String, dynamic> transfer) async =>
      (await database).insert('transfers', transfer);

  Future<int> insertGoal(GoalModel goal) async =>
      (await database).insert('goals', goal.toMap());
  Future<List<GoalModel>> getAllGoals() async => (await database)
      .query('goals', orderBy: 'isCompleted ASC, deadline ASC')
      .then((rows) => rows.map(GoalModel.fromMap).toList());
  Future<int> updateGoal(GoalModel goal) async => (await database).update(
    'goals',
    goal.toMap(),
    where: 'id = ?',
    whereArgs: [goal.id],
  );
  Future<int> deleteGoal(int id) async =>
      (await database).delete('goals', where: 'id = ?', whereArgs: [id]);
  Future<void> addGoalContribution(
    int goalId,
    double amount,
    String note,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('goal_contributions', {
        'goalId': goalId,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'note': note,
      });
      final rows = await txn.query(
        'goals',
        where: 'id = ?',
        whereArgs: [goalId],
        limit: 1,
      );
      final goal = GoalModel.fromMap(rows.first);
      final current = goal.currentAmount + amount;
      await txn.update(
        'goals',
        {
          'currentAmount': current,
          'isCompleted': current >= goal.targetAmount ? 1 : 0,
        },
        where: 'id = ?',
        whereArgs: [goalId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getGoalContributions(int goalId) async =>
      (await database).query(
        'goal_contributions',
        where: 'goalId = ?',
        whereArgs: [goalId],
        orderBy: 'date DESC',
      );

  Future<int> insertDebt(DebtModel debt) async =>
      (await database).insert('debts', debt.toMap());
  Future<List<DebtModel>> getAllDebts() async => (await database)
      .query('debts', orderBy: 'isSettled ASC, dueDate ASC')
      .then((rows) => rows.map(DebtModel.fromMap).toList());
  Future<int> updateDebt(DebtModel debt) async => (await database).update(
    'debts',
    debt.toMap(),
    where: 'id = ?',
    whereArgs: [debt.id],
  );
  Future<int> deleteDebt(int id) async =>
      (await database).delete('debts', where: 'id = ?', whereArgs: [id]);
  Future<void> addDebtPayment(int debtId, double amount, String note) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('debt_payments', {
        'debtId': debtId,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'note': note,
      });
      final rows = await txn.query(
        'debts',
        where: 'id = ?',
        whereArgs: [debtId],
        limit: 1,
      );
      final debt = DebtModel.fromMap(rows.first);
      final paid = debt.paidAmount + amount;
      await txn.update(
        'debts',
        {'paidAmount': paid, 'isSettled': paid >= debt.totalAmount ? 1 : 0},
        where: 'id = ?',
        whereArgs: [debtId],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getDebtPayments(int debtId) async =>
      (await database).query(
        'debt_payments',
        where: 'debtId = ?',
        whereArgs: [debtId],
        orderBy: 'date DESC',
      );

  Future<Map<String, List<Map<String, dynamic>>>> exportAllData() async {
    final db = await database;
    final tables = [
      'categories',
      'accounts',
      'transactions',
      'budgets',
      'transfers',
      'goals',
      'goal_contributions',
      'debts',
      'debt_payments',
    ];
    final result = <String, List<Map<String, dynamic>>>{};
    for (final table in tables) {
      result[table] = await db.query(table);
    }
    return result;
  }

  Future<void> restoreAllData(Map<String, dynamic> backup) async {
    final db = await database;
    final tables = [
      'debt_payments',
      'goal_contributions',
      'transfers',
      'transactions',
      'budgets',
      'debts',
      'goals',
      'accounts',
      'categories',
    ];
    await db.transaction((txn) async {
      for (final table in tables) {
        await txn.delete(table);
      }
      for (final table in tables.reversed) {
        final rows = (backup[table] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        for (final row in rows) {
          await txn.insert(table, row);
        }
      }
      final accountCount =
          Sqflite.firstIntValue(
            await txn.rawQuery('SELECT COUNT(*) FROM accounts'),
          ) ??
          0;
      if (accountCount == 0) {
        await txn.insert('accounts', {
          'name': 'Cash',
          'type': 'cash',
          'openingBalance': 0.0,
          'colorValue': 0xFF176B5B,
          'iconCode': 0xE8B0,
        });
      }
    });
  }

  // --- Backup & Restore ---
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('debt_payments');
    await db.delete('goal_contributions');
    await db.delete('transfers');
    await db.delete('debts');
    await db.delete('goals');
    await db.delete('accounts');
    await db.delete('transactions');
    await db.delete('budgets');
    // We might want to keep default categories or clear all?
    // Let's clear all and re-populate defaults if needed, or just clear custom ones.
    // Usually "Clear All" means everything.
    await db.delete('categories');
    await _prePopulateCategories(db);
    await _createFeatureTables(db);
  }

  Future<void> restoreData(
    List<CategoryModel> categories,
    List<TransactionModel> transactions,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('categories');

      for (var category in categories) {
        await txn.insert('categories', category.toMap());
      }
      for (var transaction in transactions) {
        await txn.insert('transactions', transaction.toMap());
      }
    });
  }
}
