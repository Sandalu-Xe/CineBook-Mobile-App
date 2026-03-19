import 'dart:convert';

// A mock encryption service demonstrating data encryption for the payment gateway
class EncryptionService {
  static const String _key = 'cinebook_secure_vault_key_2026';

  // Basic XOR cipher combined with Base64 encoding to demonstrate encrypted persistence
  static String encryptData(String plainText) {
    if (plainText.isEmpty) return plainText;
    List<int> result = [];
    for (int i = 0; i < plainText.length; i++) {
      result.add(plainText.codeUnitAt(i) ^ _key.codeUnitAt(i % _key.length));
    }
    return base64Encode(result);
  }

  static String decryptData(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;
    try {
      List<int> decoded = base64Decode(encryptedText);
      String result = '';
      for (int i = 0; i < decoded.length; i++) {
        result += String.fromCharCode(decoded[i] ^ _key.codeUnitAt(i % _key.length));
      }
      return result;
    } catch (e) {
      return "Decryption Error";
    }
  }
}
