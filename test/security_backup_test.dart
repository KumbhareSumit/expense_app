import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:personal_expense_tracker_app/database/db_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Security Suite: SEC-01, SEC-02 & SEC-04 Tests', () {
    test('SEC-04: exportAllData generates envelope with valid metadata', () async {
      final dbHelper = DBHelper();
      final backup = await dbHelper.exportAllData(encrypt: false);

      expect(backup['app'], equals('personal_expense_tracker_app'));
      expect(backup['version'], equals(1));
      expect(backup['schemaVersion'], equals(5));
      expect(backup.containsKey('exportedAt'), isTrue);
      expect(backup.containsKey('checksum'), isTrue);
      expect(backup.containsKey('data'), isTrue);

      final dataJson = jsonEncode(backup['data']);
      final calculatedChecksum = sha256.convert(utf8.encode(dataJson)).toString();
      expect(backup['checksum'], equals(calculatedChecksum));
    });

    test('SEC-04: restoreAllData rejects tampered backup with invalid checksum', () async {
      final dbHelper = DBHelper();
      final backup = await dbHelper.exportAllData(encrypt: false);

      // Tamper with data without updating checksum
      final dataMap = Map<String, dynamic>.from(backup['data'] as Map);
      dataMap['categories'] = [
        {
          'id': 9999,
          'name': 'Hacked Category',
          'iconCode': 1234,
          'colorValue': 0xFF000000,
          'type': 'expense',
          'isCustom': 1,
        }
      ];

      final tamperedBackup = {
        'app': 'personal_expense_tracker_app',
        'version': 1,
        'schemaVersion': 5,
        'exportedAt': backup['exportedAt'],
        'checksum': backup['checksum'], // Stale original checksum
        'data': dataMap,
      };

      expect(
        () async => await dbHelper.restoreAllData(tamperedBackup),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Backup integrity verification failed'),
        )),
      );
    });

    test('SEC-01: restoreAllData strips injected / unauthorized columns', () async {
      final dbHelper = DBHelper();
      final validData = {
        'categories': [
          {
            'id': 100,
            'name': 'Secure Category',
            'iconCode': 1001,
            'colorValue': 0xFF123456,
            'type': 'expense',
            'isCustom': 1,
            'injected_malicious_column': 'DROP TABLE users;',
          }
        ],
        'accounts': [
          {
            'id': 100,
            'name': 'Primary Vault',
            'type': 'bank',
            'openingBalance': 1000.0,
            'colorValue': 0xFF176B5B,
            'iconCode': 0xE8B0,
            'unauthorized_field': 99999,
          }
        ],
        'transactions': [],
        'budgets': [],
        'transfers': [],
        'goals': [],
        'goal_contributions': [],
        'debts': [],
        'debt_payments': [],
      };

      final dataJson = jsonEncode(validData);
      final checksum = sha256.convert(utf8.encode(dataJson)).toString();

      final backup = {
        'app': 'personal_expense_tracker_app',
        'version': 1,
        'schemaVersion': 5,
        'isEncrypted': false,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'checksum': checksum,
        'data': validData,
      };

      await dbHelper.restoreAllData(backup);

      final categories = await dbHelper.getAllCategories();
      final cat = categories.firstWhere((c) => c.id == 100);
      expect(cat.name, equals('Secure Category'));
    });

    test('SEC-01: restoreAllData rejects unknown foreign app identifier', () async {
      final dbHelper = DBHelper();
      final foreignBackup = {
        'app': 'unknown_rogue_app',
        'version': 1,
        'data': {},
      };

      expect(
        () async => await dbHelper.restoreAllData(foreignBackup),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Unrecognized application identifier'),
        )),
      );
    });

    test('SEC-05: clearAllData and relational restoration preserve foreign key integrity', () async {
      final dbHelper = DBHelper();

      await dbHelper.clearAllData();

      final categories = await dbHelper.getAllCategories();
      expect(categories.isNotEmpty, isTrue);

      final accounts = await dbHelper.getAllAccounts();
      expect(accounts.isNotEmpty, isTrue);

      final testBackupData = {
        'categories': [
          {
            'id': 500,
            'name': 'Parent Cat',
            'iconCode': 100,
            'colorValue': 0xFF123456,
            'type': 'expense',
            'isCustom': 1,
          }
        ],
        'accounts': [
          {
            'id': 500,
            'name': 'Parent Account',
            'type': 'cash',
            'openingBalance': 500.0,
            'colorValue': 0xFF176B5B,
            'iconCode': 0xE8B0,
            'createdAt': DateTime.now().toIso8601String(),
          }
        ],
        'goals': [
          {
            'id': 500,
            'name': 'Test Goal',
            'targetAmount': 5000.0,
            'currentAmount': 1000.0,
            'deadline': '2026-12-31',
            'colorValue': 0xFF123456,
            'iconCode': 0xE8B0,
            'isCompleted': 0,
          }
        ],
        'debts': [
          {
            'id': 500,
            'personName': 'Alice',
            'totalAmount': 2000.0,
            'paidAmount': 500.0,
            'type': 'lent',
            'date': '2026-10-01',
            'dueDate': '2026-11-01',
            'note': 'Test',
            'isSettled': 0,
          }
        ],
        'budgets': [
          {
            'id': 500,
            'month': 10,
            'year': 2026,
            'categoryId': 500,
            'limitAmount': 1500.0,
          }
        ],
        'transfers': [],
        'transactions': [
          {
            'id': 500,
            'amount': 250.0,
            'type': 'expense',
            'categoryId': 500,
            'accountId': 500,
            'date': '2026-10-01',
            'note': 'Coffee',
            'paymentMode': 'Cash',
            'isRecurring': 0,
          }
        ],
        'goal_contributions': [
          {
            'id': 500,
            'goalId': 500,
            'amount': 1000.0,
            'date': '2026-10-01',
            'note': 'Saved',
          }
        ],
        'debt_payments': [
          {
            'id': 500,
            'debtId': 500,
            'amount': 500.0,
            'date': '2026-10-01',
            'note': 'Part payment',
          }
        ],
      };

      final dataJson = jsonEncode(testBackupData);
      final checksum = sha256.convert(utf8.encode(dataJson)).toString();

      final backupEnvelope = {
        'app': 'personal_expense_tracker_app',
        'version': 1,
        'schemaVersion': 5,
        'isEncrypted': false,
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'checksum': checksum,
        'data': testBackupData,
      };

      await dbHelper.restoreAllData(backupEnvelope);

      final restoredTx = await dbHelper.getAllTransactions();
      expect(restoredTx.any((t) => t.id == 500), isTrue);

      final restoredDebts = await dbHelper.getAllDebts();
      expect(restoredDebts.any((d) => d.id == 500), isTrue);
    });

    test('SEC-02: AES-256 Encryption & Decryption roundtrip with EncryptionHelper', () async {
      final dbHelper = DBHelper();
      // 1. Export encrypted backup (SEC-02)
      final encryptedBackup = await dbHelper.exportAllData(encrypt: true);

      expect(encryptedBackup['isEncrypted'], isTrue);
      expect(encryptedBackup['algorithm'], equals('AES-256-CBC-PKCS7'));
      expect(encryptedBackup.containsKey('salt'), isTrue);
      expect(encryptedBackup.containsKey('iv'), isTrue);
      expect(encryptedBackup.containsKey('encryptedData'), isTrue);
      expect(encryptedBackup.containsKey('data'), isFalse); // Sensitive data is encrypted

      // 2. Restore encrypted backup successfully
      await dbHelper.restoreAllData(encryptedBackup);

      final categories = await dbHelper.getAllCategories();
      expect(categories.isNotEmpty, isTrue);
    });

    test('SEC-02: Password-protected backup fails with incorrect password and succeeds with correct password', () async {
      final dbHelper = DBHelper();
      const userSecret = 'MyStrongPassword#2026';

      // Export with custom password
      final passwordProtectedBackup = await dbHelper.exportAllData(
        password: userSecret,
        encrypt: true,
      );

      expect(passwordProtectedBackup['isEncrypted'], isTrue);
      expect(passwordProtectedBackup['requiresPassword'], isTrue);

      // Attempt restore with wrong password -> throws FormatException
      expect(
        () async => await dbHelper.restoreAllData(
          passwordProtectedBackup,
          password: 'WrongPassword123!',
        ),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('Decryption failed: Incorrect password'),
        )),
      );

      // Restore with correct password -> succeeds
      await dbHelper.restoreAllData(
        passwordProtectedBackup,
        password: userSecret,
      );

      final accounts = await dbHelper.getAllAccounts();
      expect(accounts.isNotEmpty, isTrue);
    });
  });
}
