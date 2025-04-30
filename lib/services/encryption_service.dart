import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptionService {
  static final key = Key.fromSecureRandom(32);
  static final iv = IV.fromSecureRandom(16);
  static final encrypter = Encrypter(AES(key));

  static String encrypt(String text) {
    try {
      final encrypted = encrypter.encrypt(text, iv: iv);
      return encrypted.base64;
    } catch (e) {
      print('Encryption error: $e');
      return text;
    }
  }

  static String decrypt(String encryptedText) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedText);
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      print('Decryption error: $e');
      return encryptedText;
    }
  }

  static bool isEncrypted(String text) {
    try {
      Encrypted.fromBase64(text);
      return true;
    } catch (_) {
      return false;
    }
  }
}
