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

  group('SEC-01 & SEC-04 Security Tests: Backup & Restore Validation', () {
    test('SEC-04: exportAllData generates envelope with valid SHA-256 checksum and metadata', () async {
      final dbHelper = DBHelper();
      final backup = await dbHelper.exportAllData();

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
      final backup = await dbHelper.exportAllData();

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
            'injected_malicious_column': 'DROP TABLE users;', // Injected column
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
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
        'checksum': checksum,
        'data': validData,
      };

      // Restore should succeed and strip the unauthorized columns
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
  });
}
