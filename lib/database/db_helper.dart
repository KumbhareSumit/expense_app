import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

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
      version: 1,
      onCreate: _createDB,
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
  }

  Future<void> _prePopulateCategories(Database db) async {
    final List<CategoryModel> defaultCategories = [
      CategoryModel(name: 'Food', iconCode: 58746, colorValue: 0xFFF44336, type: 'expense', isCustom: false),
      CategoryModel(name: 'Transport', iconCode: 58673, colorValue: 0xFF2196F3, type: 'expense', isCustom: false),
      CategoryModel(name: 'Shopping', iconCode: 59105, colorValue: 0xFFFF9800, type: 'expense', isCustom: false),
      CategoryModel(name: 'Entertainment', iconCode: 58914, colorValue: 0xFF9C27B0, type: 'expense', isCustom: false),
      CategoryModel(name: 'Health', iconCode: 58683, colorValue: 0xFF4CAF50, type: 'expense', isCustom: false),
      CategoryModel(name: 'Salary', iconCode: 57895, colorValue: 0xFF4CAF50, type: 'income', isCustom: false),
      CategoryModel(name: 'Investment', iconCode: 58941, colorValue: 0xFF009688, type: 'income', isCustom: false),
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
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- CRUD Operations for Transactions ---
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
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
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
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
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Backup & Restore ---
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('budgets');
    // We might want to keep default categories or clear all?
    // Let's clear all and re-populate defaults if needed, or just clear custom ones.
    // Usually "Clear All" means everything.
    await db.delete('categories');
    await _prePopulateCategories(db);
  }

  Future<void> restoreData(List<CategoryModel> categories, List<TransactionModel> transactions) async {
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
