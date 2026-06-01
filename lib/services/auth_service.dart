import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> signUp(String email, String password, String name) async {
    // محاكاة تسجيل حساب جديد
    await Future.delayed(const Duration(seconds: 1)); // محاكاة وقت التحميل
    await _secureStorage.write(key: 'uid', value: 'mock_uid_123');
  }

  Future<void> signIn(String email, String password) async {
    // محاكاة تسجيل الدخول (حساب تجريبي)
    await Future.delayed(const Duration(seconds: 1));
    
    if (password != 'sihati321' && password.length < 6) {
      throw Exception('كلمة المرور غير صحيحة');
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
