import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> signUp(String email, String password, String name) async {
    // Simulated account creation: store credentials securely
    await Future.delayed(const Duration(seconds: 1));
    await _secureStorage.write(key: 'uid', value: 'mock_uid_123');
    await _secureStorage.write(key: 'email', value: email);
    await _secureStorage.write(key: 'password', value: password);
    await _secureStorage.write(key: 'name', value: name);
  }

  Future<void> signIn(String email, String password) async {
    // Simulated login: validate against stored credentials or default manual account
    await Future.delayed(const Duration(seconds: 1));
    // Retrieve stored credentials
    final storedEmail = await _secureStorage.read(key: 'email');
    final storedPassword = await _secureStorage.read(key: 'password');
    // Allow manual account with password 'sihati321' regardless of stored email
    if ((storedEmail == null || storedEmail != email) && password != 'sihati321') {
      throw Exception('البريد غير مسجل');
    }
    if (password != 'sihati321' && (storedPassword == null || storedPassword != password)) {
      throw Exception('كلمة المرور غير صحيحة');
    }
    if (password.length < 6) {
      throw Exception('الحد الأدنى 6 أحرف لكلمة المرور');
    }
    await _secureStorage.write(key: 'uid', value: 'mock_uid_123');
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: 'uid');
  }

  Future<bool> isLoggedIn() async {
    final uid = await _secureStorage.read(key: 'uid');
    return uid != null;
  }
}
