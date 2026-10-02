import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// SEC-02: Cryptographic Security & AES-256 Encryption Helper
class EncryptionHelper {
  static const String defaultAppKeySeed = 'EXPENSE_TRACKER_AES256_SECURE_VAULT_KEY_2026';

  /// Derives a 256-bit Key from a password and salt using SHA-256 and Key Stretching
  static enc.Key deriveKey(String password, String salt) {
    List<int> keyBytes = utf8.encode(password + salt);
    // 5000 rounds of SHA-256 hashing for key stretching
    for (var i = 0; i < 5000; i++) {
      keyBytes = sha256.convert(keyBytes).bytes;
    }
    return enc.Key(Uint8List.fromList(keyBytes.sublist(0, 32)));
  }

  /// Generates a secure random 16-byte IV
  static enc.IV generateIV() {
    return enc.IV.fromSecureRandom(16);
  }

  /// Generates a secure random salt
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// Encrypts raw JSON map into a secured envelope using AES-256
  static Map<String, dynamic> encryptBackup({
    required Map<String, dynamic> data,
    String? customPassword,
  }) {
    final password = customPassword ?? defaultAppKeySeed;
    final salt = generateSalt();
    final key = deriveKey(password, salt);
    final iv = generateIV();

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final jsonPlaintext = jsonEncode(data);

    final encrypted = encrypter.encrypt(jsonPlaintext, iv: iv);
    final ciphertextBase64 = encrypted.base64;

    final checksum = sha256.convert(utf8.encode(ciphertextBase64)).toString();

    return {
      'app': 'personal_expense_tracker_app',
      'version': 1,
      'schemaVersion': 5,
      'isEncrypted': true,
      'requiresPassword': customPassword != null && customPassword.isNotEmpty,
      'algorithm': 'AES-256-CBC-PKCS7',
      'salt': salt,
      'iv': iv.base64,
      'checksum': checksum,
      'encryptedData': ciphertextBase64,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  /// Decrypts an encrypted backup envelope
  static Map<String, dynamic> decryptBackup({
    required Map<String, dynamic> envelope,
    String? customPassword,
  }) {
    if (envelope['isEncrypted'] != true) {
      // Return raw data if not marked as encrypted
      final data = envelope['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return envelope;
    }

    final ciphertext = envelope['encryptedData'] as String?;
    final salt = envelope['salt'] as String?;
    final ivBase64 = envelope['iv'] as String?;
    final expectedChecksum = envelope['checksum'] as String?;

    if (ciphertext == null || salt == null || ivBase64 == null) {
      throw const FormatException('Corrupted encryption envelope: Missing required encryption parameters.');
    }

    // Checksum verification on ciphertext before decryption
    if (expectedChecksum != null && expectedChecksum.isNotEmpty) {
      final calculatedChecksum = sha256.convert(utf8.encode(ciphertext)).toString();
      if (calculatedChecksum != expectedChecksum) {
        throw const FormatException('Ciphertext checksum mismatch: Backup file is damaged or tampered.');
      }
    }

    final password = customPassword ?? defaultAppKeySeed;
    final key = deriveKey(password, salt);
    final iv = enc.IV.fromBase64(ivBase64);

    try {
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      final decryptedJson = encrypter.decrypt64(ciphertext, iv: iv);
      final decoded = jsonDecode(decryptedJson);
      if (decoded is! Map) {
        throw const FormatException('Decrypted content is not a valid data map.');
      }
      return Map<String, dynamic>.from(decoded);
    } catch (e) {
      if (customPassword != null && customPassword.isNotEmpty) {
        throw const FormatException('Decryption failed: Incorrect password or invalid key.');
      }
      throw FormatException('Decryption error: $e');
    }
  }

  /// Encrypts an individual text string (e.g. sensitive transaction notes / account credentials)
  static String encryptSensitiveText(String text, {String? keySeed}) {
    if (text.isEmpty) return text;
    final password = keySeed ?? defaultAppKeySeed;
    const salt = 'APP_LOCAL_STATIC_SALT_2026';
    final key = deriveKey(password, salt);
    final iv = enc.IV.fromLength(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return encrypter.encrypt(text, iv: iv).base64;
  }

  /// Decrypts an individual text string
  static String decryptSensitiveText(String encryptedBase64, {String? keySeed}) {
    if (encryptedBase64.isEmpty) return encryptedBase64;
    try {
      final password = keySeed ?? defaultAppKeySeed;
      const salt = 'APP_LOCAL_STATIC_SALT_2026';
      final key = deriveKey(password, salt);
      final iv = enc.IV.fromLength(16);
      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
      return encrypter.decrypt64(encryptedBase64, iv: iv);
    } catch (_) {
      return encryptedBase64; // Return as-is if plaintext legacy
    }
  }
}
